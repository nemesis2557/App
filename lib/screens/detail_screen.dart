import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';

class DetailScreen extends StatelessWidget {
  final Pet pet;

  const DetailScreen({
    super.key,
    required this.pet,
  });

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: const Color(0xFF7C5CBF).withOpacity(0.1),
            child: const Icon(Icons.pets, size: 80, color: Color(0xFF7C5CBF)),
          );
        },
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: const Color(0xFF7C5CBF).withOpacity(0.1),
            child: const Icon(Icons.pets, size: 80, color: Color(0xFF7C5CBF)),
          );
        },
      );
    }
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF7F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Información de Contacto",
          style: TextStyle(
            fontFamily: 'Baloo 2',
            fontWeight: FontWeight.bold,
            color: Color(0xFF382B4A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Para reportes sobre ${pet.nombre}, comunícate con el dueño a través de:",
              style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF7C5CBF)),
                const SizedBox(width: 12),
                Text(
                  pet.contacto,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C5CBF),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF382B4A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Simulando llamada a ${pet.contacto}"),
                  backgroundColor: const Color(0xFF6FD9BE),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8935A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Llamar",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isOwner = appState.currentUser?.id == pet.userId;
    final bool isPerdido = pet.estado.toLowerCase() == 'perdido';
    final bool hasRecompensa = pet.recompensa != null && pet.recompensa!.isNotEmpty;

    // Formatear Fecha
    final String fechaStr = "${pet.fechaPerdida.day}/${pet.fechaPerdida.month}/${pet.fechaPerdida.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      body: CustomScrollView(
        slivers: [
          // Banner de imagen de mascota con botón de retorno
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF7C5CBF),
            leading: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(pet.fotoUrl),
            ),
          ),
          
          // Contenido de detalles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y Estado Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet.nombre,
                        style: const TextStyle(
                          fontFamily: 'Baloo 2',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF382B4A),
                        ),
                      ),
                      StatusBadge(estado: pet.estado),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Raza y Color
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5DED5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pet.raza,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF382B4A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5DED5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Color: ${pet.color}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF382B4A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Caja de Recompensa (Si Aplica)
                  if (hasRecompensa) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8935A).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8935A), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFE8935A),
                            size: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "¡Se ofrece Recompensa!",
                                  style: TextStyle(
                                    fontFamily: 'Baloo 2',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF382B4A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pet.recompensa!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE8935A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Detalles e Información
                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontFamily: 'Baloo 2',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF382B4A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet.descripcion,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Color(0xFF382B4A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Fecha y Ubicación
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Color(0xFF7C5CBF), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Fecha de extravío: $fechaStr",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF382B4A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF7C5CBF), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Última vez visto: ${pet.lugar}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF382B4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Botones de acción dinámicos
                  if (isOwner && isPerdido) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await appState.markAsFound(pet);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("¡Felicidades! Se ha marcado como encontrada."),
                                backgroundColor: Color(0xFF6FD9BE),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text(
                          "Marcar como Encontrado",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FD9BE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showContactDialog(context),
                      icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                      label: const Text(
                        "Contactar al dueño",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5CBF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
