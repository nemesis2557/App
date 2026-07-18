import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const CustomLogo({
    super.key,
    this.size = 60.0,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Corazón Morado
            Icon(
              Icons.favorite,
              size: size,
              color: const Color(0xFF7C5CBF),
            ),
            // Huella de mascota entrelazada (crema al centro)
            Positioned(
              top: size * 0.12,
              child: Icon(
                Icons.pets,
                size: size * 0.45,
                color: const Color(0xFFFBF7F1),
              ),
            ),
            // Cruz veterinaria menta flotante en la esquina inferior derecha del corazón
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF6FD9BE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          const Text(
            "Colitas Petshop",
            style: TextStyle(
              fontFamily: 'Baloo 2',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF382B4A),
            ),
          ),
          const Text(
            "Mascotas Perdidas",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF7C5CBF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
