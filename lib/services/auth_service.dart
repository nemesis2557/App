import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/app_user.dart';

class AuthService {
  late final bool _useFirebase;
  late final FirebaseAuth? _auth;

  // Mock State
  AppUser? _currentMockUser;
  final StreamController<AppUser?> _mockAuthStreamController = StreamController<AppUser?>.broadcast();

  AuthService() {
    _useFirebase = Firebase.apps.isNotEmpty;
    _auth = _useFirebase ? FirebaseAuth.instance : null;
    
    // Seed initial mock auth state (starts as null/visitor)
    _mockAuthStreamController.add(null);
  }

  Stream<AppUser?> get authStateChanges {
    if (_useFirebase && _auth != null) {
      return _auth!.authStateChanges().map((user) {
        if (user == null) return null;
        return AppUser(
          id: user.uid,
          nombre: user.displayName ?? 'Usuario registrado',
          correo: user.email ?? '',
        );
      });
    } else {
      return _mockAuthStreamController.stream;
    }
  }

  AppUser? get currentUser {
    if (_useFirebase && _auth != null) {
      final user = _auth!.currentUser;
      if (user == null) return null;
      return AppUser(
        id: user.uid,
        nombre: user.displayName ?? 'Usuario registrado',
        correo: user.email ?? '',
      );
    } else {
      return _currentMockUser;
    }
  }

  Future<AppUser?> signIn(String email, String password) async {
    if (_useFirebase && _auth != null) {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        return AppUser(
          id: user.uid,
          nombre: user.displayName ?? 'Usuario registrado',
          correo: user.email ?? '',
        );
      }
      return null;
    } else {
      // Simulation of a brief delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception("El correo y la contraseña son obligatorios.");
      }
      if (password.length < 6) {
        throw Exception("La contraseña debe tener al menos 6 caracteres.");
      }

      // Mock user login
      _currentMockUser = AppUser(
        id: 'mock-user-123',
        nombre: email.split('@')[0].toUpperCase(),
        correo: email,
      );
      _mockAuthStreamController.add(_currentMockUser);
      return _currentMockUser;
    }
  }

  Future<AppUser?> signUp(String nombre, String email, String password) async {
    if (_useFirebase && _auth != null) {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(nombre);
        return AppUser(
          id: user.uid,
          nombre: nombre,
          correo: email,
        );
      }
      return null;
    } else {
      // Simulation of a brief delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception("Todos los campos son obligatorios.");
      }
      if (password.length < 6) {
        throw Exception("La contraseña debe tener al menos 6 caracteres.");
      }

      _currentMockUser = AppUser(
        id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        nombre: nombre,
        correo: email,
      );
      _mockAuthStreamController.add(_currentMockUser);
      return _currentMockUser;
    }
  }

  Future<void> signOut() async {
    if (_useFirebase && _auth != null) {
      await _auth!.signOut();
    } else {
      _currentMockUser = null;
      _mockAuthStreamController.add(null);
    }
  }
}
