import 'dart:convert';
import 'package:http/http.dart' as http;

class DataService {
  final String baseUrl;

  DataService(this.baseUrl);

  Future<Map<String, dynamic>> fetchSensorData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sensor data');
    }
  }
}
