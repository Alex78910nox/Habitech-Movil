import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'dart:convert';
import '../colors.dart';

class PaymentsPage extends StatefulWidget {
  final int residenteId;
  const PaymentsPage({super.key, required this.residenteId});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<dynamic> pagos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPagos();
  }

  Future<void> fetchPagos() async {
    try {
      final response = await http.get(Uri.parse('https://apitaller.onrender.com/api/pagos/residente/${widget.residenteId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          setState(() {
            pagos = data['datos'];
            loading = false;
          });
        } else {
          setState(() {
            error = data['mensaje'] ?? 'Error desconocido';
            loading = false;
          });
        }
      } else {
        setState(() {
          error = 'Error de red: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> crearPagoStripe(Map pago) async {
    final url = Uri.parse('https://apitaller.onrender.com/api/pagos/crear');
    
    final descripcionValue = getDescripcion(pago);
    final montoValue = double.tryParse(pago['monto'].toString()) ?? 0.0;
    
    final body = {
      'residenteId': widget.residenteId,
      'monto': montoValue,
      'descripcion': descripcionValue.isEmpty ? 'Pago de servicio' : descripcionValue,
    };
    
    print('Enviando al backend: ${json.encode(body)}');
    
    try {
      final response = await http.post(url, body: json.encode(body), headers: {'Content-Type': 'application/json'});
      
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
        );
        return;
      }
      
      // Verificar si la respuesta es JSON
      if (!response.body.startsWith('{')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Respuesta inválida del servidor. Verifica que la ruta /api/pagos/crear existe')),
        );
        print('Respuesta NO es JSON: ${response.body.substring(0, 100)}');
        return;
      }
      
      final data = json.decode(response.body);
      if (data['exito'] == true && data['clientSecret'] != null) {
        // Mostrar formulario de pago de Stripe
        await mostrarFormularioPago(data['clientSecret']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['mensaje'] ?? 'No se pudo crear el pago'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear pago: $e')),
      );
      print('Error completo: $e');
    }
  }

  Future<void> mostrarFormularioPago(String clientSecret) async {
    try {
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Habitech',
          style: ThemeMode.light,
        ),
      );
      
      await stripe.Stripe.instance.presentPaymentSheet();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pago completado exitosamente!')),
      );
      
      // Recargar pagos para ver el cambio de estado
      fetchPagos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago cancelado o error: $e')),
      );
    }
  }

  String getDescripcion(Map pago) {
    if (pago.containsKey('descripcion') && pago['descripcion'] != null) {
      return pago['descripcion'].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : pagos.isEmpty
                  ? Center(child: Text('No hay pagos para mostrar', style: TextStyle(color: HabitechColors.azulOscuro)))
                  : ListView.builder(
                      itemCount: pagos.length,
                      itemBuilder: (context, index) {
                        final pago = pagos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('${pago['tipo_pago']} - ${pago['estado']}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Monto: ${pago['monto']}'),
                                Text('Descripción: ${getDescripcion(pago)}'),
                                Text('Vence: ${pago['fecha_vencimiento']?.substring(0,10) ?? ''}'),
                                if (pago['estado'] == 'pendiente')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.payment),
                                      label: Text('Pagar'),
                                      onPressed: () => crearPagoStripe(pago),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: pago['estado'] == 'pendiente'
                                ? Icon(Icons.warning, color: Colors.orange)
                                : Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      },
                    ),
    );
  }
}
