import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../screens/login_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382B4A).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_rounded,
                label: "Inicio",
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.add_circle_outline_rounded,
                label: "Publicar",
                requiresAuth: true,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.person_rounded,
                label: "Perfil",
                requiresAuth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    bool requiresAuth = false,
  }) {
    final appState = Provider.of<AppState>(context, listen: false);
    final bool isSelected = currentIndex == index;
    final Color activeColor = const Color(0xFF7C5CBF);
    final Color inactiveColor = const Color(0xFF382B4A).withOpacity(0.5);

    return InkWell(
      onTap: () {
        if (requiresAuth && !appState.isAuthenticated) {
          // Redirect to Login if authentication is required
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                onLoginSuccess: () {
                  // After successful login, close login screen and switch tab
                  Navigator.pop(context);
                  onTap(index);
                },
              ),
            ),
          );
        } else {
          onTap(index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
