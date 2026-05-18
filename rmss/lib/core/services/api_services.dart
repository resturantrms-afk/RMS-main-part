import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiServices {
  static Future<String?> uploadImage(File imageFile) async {
    final String apiKey = dotenv.env['IMGBB_API_KEY'] ?? '';

    try {
      final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");
      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['url'];
      } else {
        //print('Failed to upload image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //print('Error uploading image: $e');
      return null;
    }
  }
}
