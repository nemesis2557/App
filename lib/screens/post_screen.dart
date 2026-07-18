import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../providers/app_state.dart';

class PostScreen extends StatefulWidget {
  final Pet? petToEdit;
  final VoidCallback onSuccess;

  const PostScreen({
    super.key,
    this.petToEdit,
    required this.onSuccess,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _colorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _lugarController = TextEditingController();
  final _contactoController = TextEditingController();
  final _recompensaController = TextEditingController();
  
  DateTime _fechaPerdida = DateTime.now();
  String _estado = 'Perdido'; // 'Perdido' | 'Encontrado'
  
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.petToEdit != null;
    
    if (_isEditMode) {
      final pet = widget.petToEdit!;
      _nombreController.text = pet.nombre;
      _razaController.text = pet.raza;
      _colorController.text = pet.color;
      _descripcionController.text = pet.descripcion;
      _lugarController.text = pet.lugar;
      _contactoController.text = pet.contacto;
      _recompensaController.text = pet.recompensa ?? '';
      _fechaPerdida = pet.fechaPerdida;
      _estado = pet.estado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _descripcionController.dispose();
    _lugarController.dispose();
    _contactoController.dispose();
    _recompensaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaPerdida,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C5CBF), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF382B4A), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7C5CBF), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaPerdida) {
      setState(() {
        _fechaPerdida = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFBF7F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF7C5CBF)),
              title: const Text('Galería', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF7C5CBF)),
              title: const Text('Cámara', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isEditMode && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor selecciona una fotografía de la mascota."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      if (_isEditMode) {
        await appState.updatePetDetails(
          petId: widget.petToEdit!.id,
          nombre: _nombreController.text.trim(),
          raza: _razaController.text.trim(),
          color: _colorController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          fechaPerdida: _fechaPerdida,
          lugar: _lugarController.text.trim(),
          contacto: _contactoController.text.trim(),
          recompensa: _recompensaController.text.trim(),
          estado: _estado,
          existingFotoUrl: widget.petToEdit!.fotoUrl,
          newImageFile: _selectedImageFile,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Publicación editada con éxito!"),
            backgroundColor: Color(0xFF6FD9BE),
          ),
        );
      } else {
        await appState.createPet(
          nombre: _nombreController.text.trim(),
          raza: _razaController.text.trim(),
          color: _colorController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          fechaPerdida: _fechaPerdida,
          lugar: _lugarController.text.trim(),
          contacto: _contactoController.text.trim(),
          recompensa: _recompensaController.text.trim(),
          estado: _estado,
          imageFile: _selectedImageFile,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Mascota reportada con éxito!"),
            backgroundColor: Color(0xFF6FD9BE),
          ),
        );
      }
      
      // Execute success callback (redirect or pop)
      widget.onSuccess();
      
      // Clean up fields if we created a new one and didn't pop
      if (!_isEditMode) {
        _nombreController.clear();
        _razaController.clear();
        _colorController.clear();
        _descripcionController.clear();
        _lugarController.clear();
        _contactoController.clear();
        _recompensaController.clear();
        setState(() {
          _selectedImageFile = null;
          _fechaPerdida = DateTime.now();
          _estado = 'Perdido';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      );
    } else if (_isEditMode) {
      final String path = widget.petToEdit!.fotoUrl;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        );
      } else {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        );
      }
    } else {
      return Container(
        height: 200,
        color: const Color(0xFF7C5CBF).withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Color(0xFF7C5CBF),
            ),
            const SizedBox(height: 8),
            Text(
              "Agregar fotografía",
              style: TextStyle(
                fontFamily: 'Inter',
                color: const Color(0xFF382B4A).withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Formatos JPG o PNG (Obligatorio)",
              style: TextStyle(
                fontFamily: 'Inter',
                color: const Color(0xFF382B4A).withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String titleText = _isEditMode ? "Editar caso" : "Reportar Mascota";
    final String buttonText = _isEditMode ? "Guardar cambios" : "Publicar reporte";
    final String subtitleText = _isEditMode ? "Modifica los datos del reporte" : "Completa la información para iniciar la búsqueda";

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF7F1),
        elevation: 0,
        leading: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF382B4A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          titleText,
          style: const TextStyle(
            fontFamily: 'Baloo 2',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF382B4A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: const Color(0xFF382B4A).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Imagen Selector
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF7C5CBF).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildImagePreview(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Estado del Reporte (Perdido / Encontrado)
                const Text(
                  "Estado del caso",
                  style: TextStyle(
                    fontFamily: 'Baloo 2',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382B4A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text("PERDIDO")),
                        selected: _estado == 'Perdido',
                        onSelected: (selected) {
                          if (selected) setState(() => _estado = 'Perdido');
                        },
                        selectedColor: const Color(0xFF7C5CBF),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: _estado == 'Perdido' ? Colors.white : const Color(0xFF382B4A),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _estado == 'Perdido' ? Colors.transparent : const Color(0xFFE5DED5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text("ENCONTRADO")),
                        selected: _estado == 'Encontrado',
                        onSelected: (selected) {
                          if (selected) setState(() => _estado = 'Encontrado');
                        },
                        selectedColor: const Color(0xFF6FD9BE),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: _estado == 'Encontrado' ? Colors.white : const Color(0xFF382B4A),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _estado == 'Encontrado' ? Colors.transparent : const Color(0xFFE5DED5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nombre Mascota
                _buildLabel("Nombre de la mascota"),
                _buildTextFormField(
                  controller: _nombreController,
                  hintText: "Ej. Rocky, Bruno, Michi",
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "El nombre es obligatorio";
                    return null;
                  },
                ),
                
                // Raza
                _buildLabel("Raza"),
                _buildTextFormField(
                  controller: _razaController,
                  hintText: "Ej. Golden Retriever, Siamés, Mestizo",
                  icon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "La raza es obligatoria";
                    return null;
                  },
                ),

                // Color y Características
                _buildLabel("Color y características"),
                _buildTextFormField(
                  controller: _colorController,
                  hintText: "Ej. Marrón con manchas blancas, collar rojo",
                  icon: Icons.color_lens_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Este campo es obligatorio";
                    return null;
                  },
                ),

                // Descripción
                _buildLabel("Descripción detallada"),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A)),
                  decoration: InputDecoration(
                    hintText: "Escribe cómo se perdió, detalles de temperamento, marcas...",
                    hintStyle: TextStyle(fontFamily: 'Inter', color: const Color(0xFF382B4A).withOpacity(0.4), fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "La descripción es obligatoria";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Fecha pérdida
                _buildLabel("Fecha en que se perdió / encontró"),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color(0xFF7C5CBF)),
                            const SizedBox(width: 12),
                            Text(
                              "${_fechaPerdida.day}/${_fechaPerdida.month}/${_fechaPerdida.year}",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF382B4A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF7C5CBF)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lugar
                _buildLabel("Lugar donde fue visto por última vez"),
                _buildTextFormField(
                  controller: _lugarController,
                  hintText: "Ej. Av. Sesquicentenario, Plaza de San Jerónimo",
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "El lugar es obligatorio";
                    return null;
                  },
                ),

                // Datos de contacto
                _buildLabel("Número de celular / contacto"),
                _buildTextFormField(
                  controller: _contactoController,
                  hintText: "Ej. 983654321",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "El contacto es obligatorio";
                    return null;
                  },
                ),

                // Recompensa (Opcional)
                _buildLabel("Recompensa (Opcional)"),
                _buildTextFormField(
                  controller: _recompensaController,
                  hintText: "Ej. S/. 150, S/. 300",
                  icon: Icons.emoji_events_outlined,
                ),
                
                const SizedBox(height: 32),

                // Botón Guardar / Publicar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: appState.isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CBF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: appState.isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Baloo 2',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF382B4A),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: 'Inter', color: const Color(0xFF382B4A).withOpacity(0.4), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: const Color(0xFF7C5CBF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
