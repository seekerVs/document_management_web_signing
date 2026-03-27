import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Model/signing_session_model.dart';

class DocumentProvider {
  final String baseUrl;

  DocumentProvider({required this.baseUrl});

  /// Fetches the signature request metadata (signers, fields, document info)
  Future<SignatureRequestModel> getSignatureRequest(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/guest/request-details?token=$token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SignatureRequestModel.fromMap(data['data'], data['id']);
    } else {
      throw Exception('Failed to load signature request: ${response.statusCode}');
    }
  }

  /// Fetches the actual PDF document bytes
  Future<Uint8List> getDocumentBytes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/guest/document-bytes?token=$token'),
      headers: {
        'Accept': 'application/pdf',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load document bytes: ${response.statusCode}');
    }
  }

  /// Submits the final signed document or signature data
  Future<void> submitSignature({
    required String token,
    required List<Map<String, dynamic>> signatureData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/guest/submit-signature?token=$token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'signatures': signatureData,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit signatures: ${response.statusCode}');
    }
  }
}
