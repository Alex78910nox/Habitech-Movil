import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../colors.dart';

class DashboardPage extends StatefulWidget {
  final int departamentoId;
  const DashboardPage({super.key, required this.departamentoId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> metricas = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMetricas();
  }

  Future<void> fetchMetricas() async {
    try {
      final response = await http.get(
        Uri.parse('https://apitaller.onrender.com/api/metricas_consumo/departamento/${widget.departamentoId}')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          setState(() {
            metricas = data['datos'];
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

  IconData getIconForService(String servicio) {
    switch (servicio.toLowerCase()) {
      case 'luz':
        return Icons.lightbulb;
      case 'agua':
        return Icons.water_drop;
      case 'gas':
        return Icons.local_fire_department;
      case 'internet':
        return Icons.wifi;
      default:
        return Icons.bolt;
    }
  }

  Color getColorForService(String servicio) {
    switch (servicio.toLowerCase()) {
      case 'luz':
        return Colors.amber;
      case 'agua':
        return Colors.blue;
      case 'gas':
        return Colors.orange;
      case 'internet':
        return Colors.purple;
      default:
        return HabitechColors.azulElectrico;
    }
  }

  String getUnidadForService(String servicio) {
    switch (servicio.toLowerCase()) {
      case 'luz':
        return 'kWh';
      case 'agua':
        return 'm³';
      case 'gas':
        return 'm³';
      case 'internet':
        return 'GB';
      default:
        return '';
    }
  }

  double getTotalConsumo() {
    return metricas.fold(0.0, (sum, metrica) => 
      sum + (double.tryParse(metrica['consumo'].toString()) ?? 0.0)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: HabitechColors.azulOscuro,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        label: Text('Reintentar'),
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          fetchMetricas();
                        },
                      ),
                    ],
                  ),
                )
              : metricas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, 
                            size: 80, 
                            color: HabitechColors.azulElectrico.withOpacity(0.5)
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay métricas de consumo',
                            style: TextStyle(
                              fontSize: 18,
                              color: HabitechColors.azulOscuro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Los datos aparecerán aquí cuando se registren',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchMetricas,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de resumen total
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    HabitechColors.azulOscuro,
                                    HabitechColors.azulElectrico,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: HabitechColors.azulElectrico.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.analytics,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Resumen de Consumo',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${metricas.length} Servicios',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Departamento #${widget.departamentoId}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),

                            // Título de la sección
                            Text(
                              'Métricas por Servicio',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: HabitechColors.azulOscuro,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Lista de métricas
                            ...metricas.map((metrica) {
                              final tipoServicio = metrica['tipo_servicio'] ?? '';
                              final consumo = double.tryParse(metrica['consumo'].toString()) ?? 0.0;
                              final fechaRegistro = metrica['fecha_registro'] ?? '';
                              final fecha = fechaRegistro.isNotEmpty 
                                  ? fechaRegistro.substring(0, 10) 
                                  : 'Sin fecha';

                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: getColorForService(tipoServicio).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      getIconForService(tipoServicio),
                                      color: getColorForService(tipoServicio),
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    tipoServicio.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: HabitechColors.azulOscuro,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        'Registrado: $fecha',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        consumo.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: getColorForService(tipoServicio),
                                        ),
                                      ),
                                      Text(
                                        getUnidadForService(tipoServicio),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                            SizedBox(height: 16),

                            // Botón de actualizar
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.refresh),
                                label: Text('Actualizar Datos'),
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  fetchMetricas();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: HabitechColors.azulElectrico),
                                  foregroundColor: HabitechColors.azulElectrico,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
