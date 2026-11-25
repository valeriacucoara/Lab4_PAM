import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoreApiException implements Exception {
  final String message;
  const StoreApiException(this.message);
  @override
  String toString() => message;
}

/// Cereri reale catre serviciul REST, nu catre assets/data.
class StoreApiService {
  static const String baseUrl = 'https://test-api-jlbn.onrender.com/lab2026/v1';
  final http.Client client;
  StoreApiService(this.client);

  Future<Map<String, dynamic>> getFeed() => _get('/feed');
  Future<Map<String, dynamic>> getDetails() => _get('/feed/details');

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl$path'), headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) {
        throw StoreApiException('Serverul a raspuns HTTP ${response.statusCode}.');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const StoreApiException('Raspunsul API nu este un obiect JSON valid.');
      }
      return decoded;
    } on TimeoutException {
      throw const StoreApiException('Conexiunea a expirat. Verifica internetul si reincearca.');
    } on http.ClientException catch (e) {
      throw StoreApiException('Eroare de conexiune: ${e.message}');
    } on FormatException {
      throw const StoreApiException('Serverul a trimis JSON invalid.');
    }
  }
}
