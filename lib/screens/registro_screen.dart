import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_logo.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrarse() async {
    // 1. Validar el formulario localmente antes de enviar la petición
    if (!_formKey.currentState!.validate()) return;

    // Validación de longitud mínima de contraseña previa al envío
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener como mínimo 6 caracteres."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Crear usuario oficial en Firebase Auth con .trim() aplicado al correo electrónico
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Evitar errores de "BuildContext across async gaps" si el widget se desmonto
      if (!mounted) return;

      // 3. Ejecutar de forma segura sendEmailVerification si el registro fue exitoso
      final user = userCredential.user;
      if (user != null) {
        // Opcional: Actualizar el nombre en el perfil antes de verificar
        if (_nombreController.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nombreController.text.trim());
          if (!mounted) return;
        }

        // Enviar correo de verificación nativo
        await user.sendEmailVerification();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "¡Cuenta creada con éxito! Te hemos enviado un correo de verificación. Por favor confírmalo para continuar.",
              style: TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Color(0xFF6FD9BE),
          ),
        );

        // Regresar a la pantalla anterior (Login) tras el éxito
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // 4. Capturar errores específicos (ej: weak-password, email-already-in-use)
      String mensaje = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      
      switch (e.code) {
        case 'email-already-in-use':
          mensaje = "Este correo electrónico ya está registrado por otra cuenta.";
          break;
        case 'invalid-email':
          mensaje = "El correo electrónico ingresado no es válido.";
          break;
        case 'operation-not-allowed':
          mensaje = "El registro con correo/contraseña no está habilitado.";
          break;
        case 'weak-password':
          mensaje = "La contraseña elegida es demasiado débil. Usa al menos 6 caracteres.";
          break;
        default:
          if (e.message != null) {
            mensaje = e.message!;
          }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString().replaceAll("Exception: ", "")}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores del tema de la app
    const Color brandPurple = Color(0xFF7C5CBF);
    const Color textDark = Color(0xFF382B4A);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomLogo(size: 70, showText: true),
                const SizedBox(height: 30),
                
                Text(
                  "Crear Cuenta Nueva",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Baloo 2',
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Regístrate para reportar o buscar mascotas perdidas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: textDark.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Campo Nombre Completo
                TextFormField(
                  controller: _nombreController,
                  keyboardType: TextInputType.name,
                  style: const TextStyle(fontFamily: 'Inter', color: textDark),
                  decoration: InputDecoration(
                    labelText: "Nombre completo",
                    labelStyle: const TextStyle(fontFamily: 'Inter', color: brandPurple),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person_outline, color: brandPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa tu nombre completo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Correo Electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Inter', color: textDark),
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    labelStyle: const TextStyle(fontFamily: 'Inter', color: brandPurple),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email_outlined, color: brandPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa tu correo electrónico";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return "Ingresa un correo electrónico válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontFamily: 'Inter', color: textDark),
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    labelStyle: const TextStyle(fontFamily: 'Inter', color: brandPurple),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, color: brandPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: brandPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa tu contraseña";
                    }
                    if (value.length < 6) {
                      return "La contraseña debe tener al menos 6 caracteres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Confirmar Contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(fontFamily: 'Inter', color: textDark),
                  decoration: InputDecoration(
                    labelText: "Confirmar contraseña",
                    labelStyle: const TextStyle(fontFamily: 'Inter', color: brandPurple),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, color: brandPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: brandPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor confirma tu contraseña";
                    }
                    if (value != _passwordController.text) {
                      return "Las contraseñas no coinciden";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botón Registrarse / Indicador de Carga
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text(
                            "Registrarse",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
