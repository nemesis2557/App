import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String estado;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.estado,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEncontrado = estado.toLowerCase() == 'encontrado';
    final Color backgroundColor = isEncontrado 
        ? const Color(0xFF6FD9BE).withOpacity(0.15) 
        : const Color(0xFF7C5CBF).withOpacity(0.15);
    final Color textColor = isEncontrado 
        ? const Color(0xFF1E8267) 
        : const Color(0xFF7C5CBF);
    final IconData icon = isEncontrado ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: textColor),
          const SizedBox(width: 4),
          Text(
            estado.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
