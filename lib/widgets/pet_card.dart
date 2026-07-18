import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../screens/detail_screen.dart';
import 'status_badge.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF7C5CBF).withOpacity(0.1),
            child: const Icon(Icons.pets, size: 40, color: Color(0xFF7C5CBF)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFFBF7F1),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CBF)),
              ),
            ),
          );
        },
      );
    } else {
      // Local image file path (from ImagePicker)
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF7C5CBF).withOpacity(0.1),
            child: const Icon(Icons.pets, size: 40, color: Color(0xFF7C5CBF)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRecompensa = pet.recompensa != null && pet.recompensa!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382B4A).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(pet: pet),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la mascota y badge de estado
                Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _buildImage(pet.fotoUrl),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: StatusBadge(estado: pet.estado),
                    ),
                    if (hasRecompensa)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8935A),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Recompensa",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Detalles de la mascota
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pet.nombre,
                            style: const TextStyle(
                              fontFamily: 'Baloo 2',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF382B4A),
                            ),
                          ),
                          if (hasRecompensa)
                            Text(
                              pet.recompensa!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE8935A),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.raza,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: const Color(0xFF382B4A).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1, color: Color(0xFFE5DED5)),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF7C5CBF),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pet.lugar,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Color(0xFF382B4A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
