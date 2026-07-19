import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  // Controladores para capturar lo que el usuario escribe
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  File? _imagenSeleccionada;
  bool _estaCargando = false;
  final ImagePicker _picker = ImagePicker();

  // Función para abrir la cámara o galería
  Future<void> _seleccionarImagen(ImageSource fuente) async {
    try {
      final XFile? archivo = await _picker.pickImage(
        source: fuente,
        imageQuality: 70, // Optimiza el tamaño para que suba más rápido
      );
      if (archivo != null) {
        setState(() {
          _imagenSeleccionada = File(archivo.path);
        });
      }
    } catch (e) {
      _mostrarMensaje("Error al seleccionar imagen: $e", esError: true);
    }
  }

  // --- NUEVA FUNCIÓN PARA SUBIR DIRECTAMENTE A SUPABASE STORAGE ---
  Future<String?> _subirASupabaseStorage() async {
    if (_imagenSeleccionada == null) return null;

    try {
      // Creamos un nombre de archivo único usando los milisegundos actuales para evitar duplicados
      final String nombreArchivo = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      
      // 1. Subir el archivo binario al bucket 'imagenes_mascotas'
      await Supabase.instance.client.storage
          .from('imagenes_mascotas')
          .upload(nombreArchivo, _imagenSeleccionada!);

      // 2. Obtener la URL pública oficial generada por Supabase
      final String urlPublica = Supabase.instance.client.storage
          .from('imagenes_mascotas')
          .getPublicUrl(nombreArchivo);

      return urlPublica;
    } catch (e) {
      debugPrint("Error detallado en Storage: $e");
      return null;
    }
  }

  // Función principal para guardar el producto/mascota en Supabase
  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imagenSeleccionada == null) {
      _mostrarMensaje("Por favor, captura o selecciona una foto.", esError: true);
      return;
    }

    setState(() => _estaCargando = true);

    try {
      // 1. Subir la imagen al Storage de Supabase
      final String? urlFoto = await _subirASupabaseStorage();

      if (urlFoto == null) {
        throw "No se pudo subir la foto a Supabase Storage. Verifica que el cubo sea público.";
      }

      // 2. Insertar los datos en tu tabla de Supabase con la nueva URL
      await Supabase.instance.client.from('productos').insert({
        'nombre': _nombreController.text.trim(),
        'precio': double.parse(_precioController.text.trim()),
        'foto_url': urlFoto,
      });

      _mostrarMensaje("¡Reporte guardado exitosamente! 🐾");
      
      // Limpiar el formulario
      _nombreController.clear();
      _precioController.clear();
      setState(() => _imagenSeleccionada = null);
      
    } catch (e) {
      _mostrarMensaje("Error al guardar: $e", esError: true);
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : const Color(0xFF7C5CBF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _estaCargando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.primary),
                  const SizedBox(height: 16),
                  Text("Guardando reporte en Supabase...", 
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- ÁREA DE VISTA PREVIA DE IMAGEN ---
                    GestureDetector(
                      onTap: () => _mostrarOpcionesCamara(),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colors.primary.withOpacity(0.2), width: 2),
                        ),
                        child: _imagenSeleccionada != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 50, color: colors.primary),
                                  const SizedBox(height: 8),
                                  Text("Toca para tomar foto de la mascota",
                                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- INPUT NOMBRE ---
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Mascota / Reporte',
                        hintText: 'Ej. Perrito callejero herido / Firulais',
                        prefixIcon: Icon(Icons.pets_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Escribe un nombre' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- INPUT PRECIO / DATO ADICIONAL ---
                    TextFormField(
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Número de contacto o edad ficticia (\$)',
                        hintText: 'Ej. 912345678',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Escribe un número';
                        if (double.tryParse(value) == null) return 'Ingresa un número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // --- BOTÓN DE GUARDAR ---
                    ElevatedButton(
                      onPressed: _guardarProducto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shadowColor: colors.primary.withOpacity(0.3),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Publicar Reporte',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Ventana flotante inferior para elegir Cámara o Galería
  void _mostrarOpcionesCamara() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF7C5CBF)),
                title: const Text('Tomar Foto con Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFE8935A)),
                title: const Text('Elegir desde la Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}