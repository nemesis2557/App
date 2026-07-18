import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/app_state.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Function(Pet) onEditPet;

  const ProfileScreen({
    super.key,
    required this.onEditPet,
  });

  Widget _buildPetThumbnail(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: const Color(0xFF7C5CBF).withOpacity(0.1),
          child: const Icon(Icons.pets, color: Color(0xFF7C5CBF)),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: const Color(0xFF7C5CBF).withOpacity(0.1),
          child: const Icon(Icons.pets, color: Color(0xFF7C5CBF)),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppState appState, String petId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF7F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "¿Eliminar reporte?",
          style: TextStyle(
            fontFamily: 'Baloo 2',
            fontWeight: FontWeight.bold,
            color: Color(0xFF382B4A),
          ),
        ),
        content: const Text(
          "Esta acción no se puede deshacer. ¿Estás seguro de que quieres eliminar esta publicación?",
          style: TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await appState.deletePetReport(petId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reporte eliminado correctamente."),
                    backgroundColor: Color(0xFFE8935A),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Eliminar",
              style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    
    // Si no está autenticado (protección por si acaso, aunque BottomNav maneja el redireccionamiento)
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF7F1),
        body: Center(
          child: Text(
            "Por favor inicia sesión.",
            style: TextStyle(fontFamily: 'Baloo 2', color: Color(0xFF382B4A)),
          ),
        ),
      );
    }

    // Filtrar publicaciones del usuario
    final myPets = appState.pets.where((p) => p.userId == user.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF7F1),
        elevation: 0,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(
            fontFamily: 'Baloo 2',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF382B4A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF382B4A)),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await appState.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sesión cerrada."),
                  backgroundColor: Color(0xFF7C5CBF),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de información del usuario
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C5CBF), Color(0xFF4A90D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C5CBF).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nombre,
                            style: const TextStyle(
                              fontFamily: 'Baloo 2',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user.correo,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Text(
              "Mis Publicaciones",
              style: TextStyle(
                fontFamily: 'Baloo 2',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF382B4A),
              ),
            ),
          ),
          
          // Listado de sus mascotas
          Expanded(
            child: appState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CBF)),
                    ),
                  )
                : myPets.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 60),
                          const Icon(
                            Icons.post_add_outlined,
                            size: 64,
                            color: Color(0xFFE8935A),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              "Aún no tienes publicaciones",
                              style: TextStyle(
                                fontFamily: 'Baloo 2',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF382B4A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Tus mascotas reportadas aparecerán aquí.",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: const Color(0xFF382B4A).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: myPets.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final pet = myPets[index];
                          final isPerdido = pet.estado.toLowerCase() == 'perdido';

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(pet: pet),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    _buildPetThumbnail(pet.fotoUrl),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pet.nombre,
                                            style: const TextStyle(
                                              fontFamily: 'Baloo 2',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF382B4A),
                                            ),
                                          ),
                                          Text(
                                            pet.raza,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              color: const Color(0xFF382B4A).withOpacity(0.6),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isPerdido 
                                                  ? const Color(0xFF7C5CBF).withOpacity(0.1)
                                                  : const Color(0xFF6FD9BE).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              pet.estado.toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isPerdido ? const Color(0xFF7C5CBF) : const Color(0xFF1E8267),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Acciones (Editar / Eliminar)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isPerdido)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF6FD9BE)),
                                            tooltip: "Marcar Encontrado",
                                            onPressed: () async {
                                              try {
                                                await appState.markAsFound(pet);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("¡Marcado como encontrada!"),
                                                    backgroundColor: Color(0xFF6FD9BE),
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(e.toString()),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF4A90D9)),
                                          tooltip: "Editar",
                                          onPressed: () => onEditPet(pet),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          tooltip: "Eliminar",
                                          onPressed: () => _showDeleteConfirmation(context, appState, pet.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
