import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/rsa_key_model.dart';

class CryptoProvider extends ChangeNotifier {
  static const String _publicKeyHeader = '-----BEGIN PUBLIC KEY-----';
  static const String _publicKeyFooter = '-----END PUBLIC KEY-----';
  static const String _privateKeyHeader = '-----BEGIN PRIVATE KEY-----';
  static const String _privateKeyFooter = '-----END PRIVATE KEY-----';

  static bool isValidPublicKeyFormat(String key) {
    final trimmed = key.trim();
    if (!trimmed.startsWith(_publicKeyHeader) ||
        !trimmed.endsWith(_publicKeyFooter)) {
      return false;
    }
    final content = trimmed
        .replaceAll(_publicKeyHeader, '')
        .replaceAll(_publicKeyFooter, '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');
    if (content.isEmpty) return false;
    final base64RegExp = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64RegExp.hasMatch(content) && content.length >= 200;
  }

  static bool isValidPrivateKeyFormat(String key) {
    final trimmed = key.trim();
    if (!trimmed.startsWith(_privateKeyHeader) ||
        !trimmed.endsWith(_privateKeyFooter)) {
      return false;
    }
    final content = trimmed
        .replaceAll(_privateKeyHeader, '')
        .replaceAll(_privateKeyFooter, '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');
    if (content.isEmpty) return false;
    final base64RegExp = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64RegExp.hasMatch(content) && content.length >= 400;
  }

  static String formatPublicKey(String key) {
    final trimmed = key.trim();
    if (trimmed.startsWith(_publicKeyHeader)) return trimmed;
    return '$_publicKeyHeader\n$trimmed\n$_publicKeyFooter';
  }

  static String formatPrivateKey(String key) {
    final trimmed = key.trim();
    if (trimmed.startsWith(_privateKeyHeader)) return trimmed;
    return '$_privateKeyHeader\n$trimmed\n$_privateKeyFooter';
  }

  static String extractKeyContent(String key) {
    final trimmed = key.trim();
    if (trimmed.startsWith(_publicKeyHeader)) {
      return trimmed
          .replaceAll(_publicKeyHeader, '')
          .replaceAll(_publicKeyFooter, '')
          .replaceAll('\n', '')
          .replaceAll('\r', '');
    }
    if (trimmed.startsWith(_privateKeyHeader)) {
      return trimmed
          .replaceAll(_privateKeyHeader, '')
          .replaceAll(_privateKeyFooter, '')
          .replaceAll('\n', '')
          .replaceAll('\r', '');
    }
    return key.trim();
  }

  static String generateFriendlyKeyId(String publicKey) {
    try {
      final content = extractKeyContent(publicKey);
      final bytes = base64.decode(content);
      final hash = sha256.convert(bytes);
      return hash.toString().substring(0, 8).toUpperCase();
    } catch (e) {
      return DateTime.now()
          .millisecondsSinceEpoch
          .toRadixString(16)
          .substring(0, 6)
          .toUpperCase();
    }
  }

  final _storage = const FlutterSecureStorage();

  List<RsaKeyModel> _myKeys = [];
  List<RsaKeyModel> _contactKeys = [];

  List<RsaKeyModel> get myKeys => _myKeys;
  List<RsaKeyModel> get contactKeys => _contactKeys;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CryptoProvider() {
    _loadKeys();
  }

  Future<String?> _readFromStorage(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> _writeToStorage(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> _loadKeys() async {
    try {
      String? myKeysJson = await _readFromStorage('my_keys');
      String? contactKeysJson = await _readFromStorage('contact_keys');

      if (myKeysJson != null) {
        Iterable l = json.decode(myKeysJson);
        _myKeys = List<RsaKeyModel>.from(
            l.map((model) => RsaKeyModel.fromMap(model)));
      }

      if (contactKeysJson != null) {
        Iterable l = json.decode(contactKeysJson);
        _contactKeys = List<RsaKeyModel>.from(
            l.map((model) => RsaKeyModel.fromMap(model)));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando llaves: $e");
    }
  }

  Future<void> _saveKeys() async {
    try {
      await _writeToStorage(
          'my_keys', json.encode(_myKeys.map((e) => e.toMap()).toList()));
      await _writeToStorage('contact_keys',
          json.encode(_contactKeys.map((e) => e.toMap()).toList()));
      notifyListeners();
    } catch (e) {
      debugPrint("Error guardando llaves: $e");
    }
  }

  Future<void> generateNewKeyPair(String name) async {
    _setLoading(true);
    try {
      var result = await RSA.generate(2048);

      final formattedPublicKey = formatPublicKey(result.publicKey);
      final formattedPrivateKey = formatPrivateKey(result.privateKey);
      final friendlyId = generateFriendlyKeyId(formattedPublicKey);

      final newKey = RsaKeyModel(
        id: friendlyId,
        name: name,
        publicKey: formattedPublicKey,
        privateKey: formattedPrivateKey,
      );

      _myKeys.add(newKey);
      await _saveKeys();
    } catch (e) {
      debugPrint("Error generando llaves: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> importContactKey(String name, String publicKey) async {
    final formattedKey = formatPublicKey(publicKey);
    final friendlyId = generateFriendlyKeyId(formattedKey);

    final newContact = RsaKeyModel(
      id: friendlyId,
      name: name,
      publicKey: formattedKey,
    );
    _contactKeys.add(newContact);
    await _saveKeys();
  }

  Future<void> deleteKey(String id, bool isMyKey) async {
    if (isMyKey) {
      _myKeys.removeWhere((k) => k.id == id);
    } else {
      _contactKeys.removeWhere((k) => k.id == id);
    }
    await _saveKeys();
  }

  Future<String> encryptMessage(String message, RsaKeyModel contactKey) async {
    if (message.isEmpty) return "";
    try {
      return await RSA.encryptPKCS1v15(message, contactKey.publicKey);
    } catch (e) {
      return "Error al encriptar: $e";
    }
  }

  Future<String> decryptMessage(String cipherText, RsaKeyModel myKey) async {
    if (cipherText.isEmpty || myKey.privateKey == null) return "";
    try {
      return await RSA.decryptPKCS1v15(cipherText.trim(), myKey.privateKey!);
    } catch (e) {
      return "Error al desencriptar. Verifica que la llave sea correcta.\nDetalle: $e";
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
