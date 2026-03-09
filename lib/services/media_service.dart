import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MediaService {
  // بياناتك من Cloudinary بناءً على السكرين شوت
  final String cloudName = "dtriqbtas"; 
  final String uploadPreset = "Memory";

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
         final responseData = await response.stream.bytesToString();
         final jsonMap = jsonDecode(responseData);
         // بنرجع الرابط الآمن للصورة (Secure URL) عشان نعرضه أو نحفظه في Firebase
         return jsonMap['secure_url']; 
      } else {
         print("فشل الرفع: ${response.statusCode}");
         return null;
      }
    } catch (e) {
      print("حدث خطأ أثناء الرفع: $e");
      return null;
    }
  }
}
