import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/pet.dart';

class FirestoreService {
  late final bool _useFirebase;
  late final FirebaseFirestore? _db;

  // Local in-memory list for mock mode
  final List<Pet> _mockPets = [
    Pet(
      id: 'mock-1',
      nombre: 'Rocky',
      raza: 'Golden Retriever',
      color: 'Dorado',
      descripcion: 'Rocky es muy juguetón y cariñoso. Llevaba un collar rojo cuando se perdió en la plaza. Es de tamaño mediano y le teme a los cohetes.',
      fechaPerdida: DateTime.now().subtract(const Duration(days: 3)),
      lugar: 'Plaza de Armas de Andahuaylas',
      contacto: '983654321',
      recompensa: 'S/. 200',
      estado: 'Perdido',
      fotoUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=600',
      userId: 'mock-user-123', // Owner of the publication is the mock user by default so they can test marking as found
    ),
    Pet(
      id: 'mock-2',
      nombre: 'Michi',
      raza: 'Siamés',
      color: 'Gris y Blanco',
      descripcion: 'Es muy tímida, responde al nombre de Michi. Tiene ojos azules muy intensos y orejas oscuras. Se perdió cerca de las verdulerías del mercado.',
      fechaPerdida: DateTime.now().subtract(const Duration(days: 5)),
      lugar: 'Cerca del Mercado Central, Andahuaylas',
      contacto: '951753852',
      recompensa: null,
      estado: 'Perdido',
      fotoUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=600',
      userId: 'other-owner-2',
    ),
    Pet(
      id: 'mock-3',
      nombre: 'Toby',
      raza: 'Schnauzer',
      color: 'Sal y Pimienta',
      descripcion: 'Fue encontrado merodeando por el parque San Jerónimo. Es muy educado, sabe sentarse y tiene un corte de pelo característico.',
      fechaPerdida: DateTime.now().subtract(const Duration(days: 1)),
      lugar: 'Parque de San Jerónimo, Andahuaylas',
      contacto: '942852159',
      recompensa: null,
      estado: 'Encontrado',
      fotoUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&q=80&w=600',
      userId: 'other-owner-3',
    ),
  ];

  FirestoreService() {
    _useFirebase = Firebase.apps.isNotEmpty;
    _db = _useFirebase ? FirebaseFirestore.instance : null;
  }

  Future<List<Pet>> getPets() async {
    if (_useFirebase && _db != null) {
      final snapshot = await _db!
          .collection('pets')
          .orderBy('fechaPerdida', descending: true)
          .get();
      return snapshot.docs.map((doc) => Pet.fromMap(doc.id, doc.data())).toList();
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      return List.from(_mockPets);
    }
  }

  Future<void> addPet(Pet pet) async {
    if (_useFirebase && _db != null) {
      await _db!.collection('pets').add(pet.toMap());
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      // Assign id
      final newPet = pet.copyWith(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockPets.insert(0, newPet);
    }
  }

  Future<void> updatePet(Pet pet) async {
    if (_useFirebase && _db != null) {
      await _db!.collection('pets').doc(pet.id).update(pet.toMap());
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockPets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        _mockPets[index] = pet;
      }
    }
  }

  Future<void> deletePet(String petId) async {
    if (_useFirebase && _db != null) {
      await _db!.collection('pets').doc(petId).delete();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockPets.removeWhere((p) => p.id == petId);
    }
  }
}
