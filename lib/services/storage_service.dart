import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  late final bool _useFirebase;
  late final FirebaseStorage? _storage;

  StorageService() {
    _useFirebase = Firebase.apps.isNotEmpty;
    _storage = _useFirebase ? FirebaseStorage.instance : null;
  }

  Future<String> uploadPetPhoto(File imageFile, String petName) async {
    if (_useFirebase && _storage != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${petName.replaceAll(' ', '_')}.jpg';
      final ref = _storage!.ref().child('pet_photos').child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } else {
      // Simulation of a delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In mock mode, we just return the local path of the selected image
      // In Flutter, Image.file(File(path)) will render this perfectly!
      return imageFile.path;
    }
  }
}
