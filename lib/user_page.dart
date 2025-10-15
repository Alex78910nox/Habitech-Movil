import 'dart:convert';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'user_model.dart';
import 'login_page.dart';
import 'models/qr_model.dart';
import 'screens/dashboard_page.dart';
import 'screens/messages_page.dart';
import 'screens/payments_page.dart';
import 'screens/home_page.dart';
import 'screens/notifications_page.dart';

class UserPage extends StatefulWidget {
  final User user;
  const UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  QrResponse? _qrResponse;
  bool _isLoadingQr = false;

  @override
  void initState() {
    super.initState();
    _loadUserQr();
  }

  Future<void> _loadUserQr() async {
    setState(() {
      _isLoadingQr = true;
    });
    try {
      final qrResponse = await getUserQr(widget.user.id.toString());
      setState(() {
        _qrResponse = qrResponse;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el QR: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingQr = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      body: SafeArea(
        child: Column(
          children: [
            // Header con logo y botón salir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Logo simple (puedes reemplazar con Image.asset si tienes uno)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: HabitechColors.azulElectrico,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.apartment, color: HabitechColors.blancoPuro, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text('HABITECH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                      child: const Text('salir', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Avatar grande + bienvenida
            Column(
              children: [
                const Text('Bienvenido', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: HabitechColors.azulElectrico,
                  child: Text(
                    widget.user.nombre.isNotEmpty ? widget.user.nombre[0] : '',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

            // Tarjeta con datos resumidos y QR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del usuario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.user.nombre} ${widget.user.apellido}', 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 8),
                          Text('Teléfono: ${widget.user.telefono}', 
                            style: const TextStyle(color: Colors.white70)
                          ),
                          Text('Correo: ${widget.user.correo}', 
                            style: const TextStyle(color: Colors.white70)
                          ),
                          Text('Nro documento: ${widget.user.numeroDocumento}', 
                            style: const TextStyle(color: Colors.white70)
                          ),
                        ],
                      ),
                    ),
                    // Código QR
                    if (widget.user.residente != null) ...[
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          if (_isLoadingQr)
                            const SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          else if (_qrResponse != null) ...[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.memory(
                                  base64Decode(_qrResponse!.qr.image.split(',').last),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Código de acceso',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Información adicional/residente
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (widget.user.residente != null) ...[
                        Text('Datos de residente', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Relación: ${widget.user.residente!.tipoRelacion}', style: const TextStyle(color: Colors.white)),
                            Text('Entrada: ${widget.user.residente!.fechaIngreso ?? '-'}', style: const TextStyle(color: Colors.white70)),
                            Text('Contacto emergencia: ${widget.user.residente!.nombreContactoEmergencia ?? '-'}', style: const TextStyle(color: Colors.white70)),
                          ]),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (widget.user.departamento != null) ...[
                        Text('Departamento', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Número: ${widget.user.departamento!.numero}', style: const TextStyle(color: Colors.white)),
                            Text('Piso: ${widget.user.departamento!.piso} - Dormitorios: ${widget.user.departamento!.dormitorios}', style: const TextStyle(color: Colors.white70)),
                            Text('Renta: ${widget.user.departamento!.rentaMensual}', style: const TextStyle(color: Colors.white70)),
                          ]),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom navigation estático (simulado)
            Container(
              color: HabitechColors.azulOscuro,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
                    },
                    icon: Icon(Icons.pie_chart, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
                    },
                    icon: Icon(Icons.mail_outline, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      if (widget.user.residente?.id != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsPage(residenteId: widget.user.residente!.id)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No hay residente asociado a este usuario.')),
                        );
                      }
                    },
                    icon: Icon(Icons.payment, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
                    },
                    icon: Icon(Icons.home, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsPage(userId: widget.user.id),
                        ),
                      );
                    },
                    icon: Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    }
}
