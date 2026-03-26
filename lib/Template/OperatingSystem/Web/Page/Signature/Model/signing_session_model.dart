import '../../../../../Utils/Constant/enum.dart';
import 'signature_field_model.dart';

class SignerModel {
  final String signerEmail;
  final String signerName;
  final int order;
  final SignerRole role;
  final SignerStatus status;
  final List<SignatureFieldModel> fields;
  final DateTime? signedAt;
  final String? signatureImageUrl;

  SignerModel({
    required this.signerEmail,
    required this.signerName,
    this.order = 0,
    this.role = SignerRole.needsToSign,
    this.status = SignerStatus.pending,
    this.fields = const [],
    this.signedAt,
    this.signatureImageUrl,
  });

  factory SignerModel.fromMap(Map<String, dynamic> data) {
    return SignerModel(
      signerEmail: data['signerEmail'] ?? '',
      signerName: data['signerName'] ?? '',
      order: (data['order'] ?? 0).toInt(),
      role: SignerRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'needsToSign'),
        orElse: () => SignerRole.needsToSign,
      ),
      status: SignerStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignerStatus.pending,
      ),
      fields: (data['fields'] as List<dynamic>? ?? [])
          .map((f) => SignatureFieldModel.fromMap(f as Map<String, dynamic>))
          .toList(),
      signedAt: data['signedAt'] != null
          ? DateTime.tryParse(data['signedAt'].toString())
          : null,
      signatureImageUrl: data['signatureImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'signerEmail': signerEmail,
      'signerName': signerName,
      'order': order,
      'role': role.name,
      'status': status.name,
      'fields': fields.map((f) => f.toMap()).toList(),
      'signedAt': signedAt?.toIso8601String(),
      'signatureImageUrl': signatureImageUrl,
    };
  }
}

class SignatureRequestModel {
  final String requestId;
  final String documentName;
  final String documentUrl;
  final List<SignerModel> signers;
  final SignatureRequestStatus status;

  SignatureRequestModel({
    required this.requestId,
    required this.documentName,
    required this.documentUrl,
    required this.signers,
    this.status = SignatureRequestStatus.pending,
  });

  factory SignatureRequestModel.fromMap(Map<String, dynamic> data, String id) {
    return SignatureRequestModel(
      requestId: id,
      documentName: data['documentName'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      signers: (data['signers'] as List<dynamic>? ?? [])
          .map((s) => SignerModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      status: SignatureRequestStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignatureRequestStatus.pending,
      ),
    );
  }
}
