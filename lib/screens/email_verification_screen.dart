import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_logo.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _canResend = true;
  int _secondsRemaining = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 30;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _checkVerification() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      await appState.reloadCurrentUser();
      final user = appState.currentUser;
      
      if (mounted) {
        if (user != null && user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Correo verificado con éxito!"),
              backgroundColor: Color(0xFF6FD9BE),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tu correo aún no está verificado. Revisa tu bandeja de entrada o spam."),
              backgroundColor: Color(0xFFE8935A),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      await appState.sendVerificationEmail();
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Correo de verificación reenviado."),
            backgroundColor: Color(0xFF7C5CBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final appState = Provider.of<AppState>(context, listen: false);
    try {
      await appState.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesión cerrada."),
            backgroundColor: Color(0xFF382B4A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final email = user?.correo ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomLogo(size: 80, showText: true),
                const SizedBox(height: 40),
                
                // Icono decorativo de correo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CBF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: Color(0xFF7C5CBF),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Verifica tu correo",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Baloo 2',
                    color: const Color(0xFF382B4A),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Te hemos enviado un correo de verificación a:\n\n$email\n\nPor favor confírmalo para activar tu cuenta y poder publicar reportes o editar tu perfil.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF382B4A),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Botón "Ya verifiqué mi correo"
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: appState.isLoading ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CBF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: appState.isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text(
                            "Ya verifiqué mi correo",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botón "Reenviar correo"
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: (_canResend && !appState.isLoading) ? _resendEmail : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7C5CBF), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _canResend ? "Reenviar correo" : "Reenviar en ${_secondsRemaining}s",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _canResend ? const Color(0xFF7C5CBF) : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Enlace Cerrar Sesión
                TextButton.icon(
                  onPressed: appState.isLoading ? null : _signOut,
                  icon: const Icon(Icons.logout, color: Color(0xFFE8935A)),
                  label: const Text(
                    "Cerrar sesión y continuar como visitante",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFFE8935A),
                      fontWeight: FontWeight.bold,
                    ),
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
