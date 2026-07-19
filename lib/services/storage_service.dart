import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StorageService {
  // CONFIGURACIÓN DE CLOUDINARY
  // 1. Aquí pones el Cloud Name que sacas del Dashboard principal de Cloudinary
  final String _cloudName = "gis0qxtk"; 

  // 2. Aquí pones exactamente el nombre del preset que me mostraste en la foto
  final String _uploadPreset = "colitas_preset"; 
  
  // ... abajo sigue todo el resto del código que te pasé antes

  Future<String> uploadPetPhoto(File imageFile, String petName) async {
    try {
      // 1. Creamos la URL de la API de Cloudinary para subir imágenes
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      // 2. Preparamos la petición Multipart (como un formulario de envío de archivos)
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = 'pet_photos' // Guarda las fotos organizadas en esta carpeta
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      debugPrint("Subiendo imagen a Cloudinary...");
      
      // 3. Enviamos la petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 4. Evaluamos la respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final String secureUrl = responseData['secure_url']; // Esta es la URL https pública
        
        debugPrint("¡Imagen subida con éxito! URL: $secureUrl");
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception("Error de Cloudinary (${response.statusCode}): ${errorData['error']['message']}");
      }
    } catch (e) {
      debugPrint("Error en uploadPetPhoto: $e");
      // Fallback: Si algo falla, devolvemos la ruta local para que la app no se caiga
      return imageFile.path;
    }
  }
}