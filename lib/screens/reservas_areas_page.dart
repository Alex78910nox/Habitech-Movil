import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../colors.dart';
import '../models/reserva_area_model.dart';

class ReservasAreasPage extends StatefulWidget {
  final int residenteId;
  const ReservasAreasPage({super.key, required this.residenteId});

  @override
  State<ReservasAreasPage> createState() => _ReservasAreasPageState();
}

class _ReservasAreasPageState extends State<ReservasAreasPage> {
  List<ReservaArea> reservas = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReservas();
  }

  String formatearFecha(String fecha) {
    try {
      // Parsear la fecha ISO
      DateTime dateTime = DateTime.parse(fecha);
      
      // Lista de nombres de meses en español
      const meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      
      // Formatear como "10 Dic 2025"
      return '${dateTime.day} ${meses[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return fecha;
    }
  }

  Future<void> fetchReservas() async {
    try {
      final response = await http.get(
        Uri.parse('https://apitaller.onrender.com/api/reservas_areas/residente/${widget.residenteId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          setState(() {
            reservas = (data['datos'] as List)
                .map((item) => ReservaArea.fromJson(item))
                .toList();
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

  Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'confirmada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservas',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: HabitechColors.azulOscuro,
      ),
      backgroundColor: HabitechColors.azulOscuro,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          fetchReservas();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : reservas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes reservas',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aún no has realizado ninguna reserva\nde áreas comunes',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchReservas,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reservas.length,
                        itemBuilder: (context, index) {
                          final reserva = reservas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Nombre del área y estado
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reserva.nombreArea,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: HabitechColors.azulOscuro,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getEstadoColor(reserva.estado).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: getEstadoColor(reserva.estado),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              getEstadoIcon(reserva.estado),
                                              size: 16,
                                              color: getEstadoColor(reserva.estado),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              reserva.estado.toUpperCase(),
                                              style: TextStyle(
                                                color: getEstadoColor(reserva.estado),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Descripción
                                  Text(
                                    reserva.descripcionArea,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  
                                  const Divider(height: 24),
                                  
                                  // Información de la reserva
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 18, color: HabitechColors.azulElectrico),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Fecha: ${formatearFecha(reserva.fechaReserva)}',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 18, color: HabitechColors.azulElectrico),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Horario: ${reserva.horaInicio.substring(0, 5)} - ${reserva.horaFin.substring(0, 5)}',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: 18, color: HabitechColors.azulElectrico),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Capacidad: ${reserva.capacidad} personas',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Monto
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: HabitechColors.azulElectrico.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Monto a pagar:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Bs ${reserva.montoPago}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
