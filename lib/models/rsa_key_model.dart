import 'dart:convert';

class RsaKeyModel {
  final String id;
  final String name;
  final String publicKey;
  final String? privateKey;

  RsaKeyModel({
    required this.id,
    required this.name,
    required this.publicKey,
    this.privateKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }

  factory RsaKeyModel.fromMap(Map<String, dynamic> map) {
    return RsaKeyModel(
      id: map['id'],
      name: map['name'],
      publicKey: map['publicKey'],
      privateKey: map['privateKey'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RsaKeyModel.fromJson(String source) =>
      RsaKeyModel.fromMap(json.decode(source));
}
