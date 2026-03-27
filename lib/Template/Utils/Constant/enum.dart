enum SignatureFieldType {
  signature,
  initials,
  textbox,
  dateSigned,
  checkbox,
}

enum SignerRole {
  needsToSign,
  receivesACopy,
}

enum SignerStatus {
  pending,
  signed,
  declined,
}

enum SignatureRequestStatus {
  pending,
  completed,
  declined,
  expired,
}
