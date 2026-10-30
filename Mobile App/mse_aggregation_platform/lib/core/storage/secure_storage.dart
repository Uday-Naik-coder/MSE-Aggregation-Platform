import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage _instance = SecureStorage._();
  factory SecureStorage() => _instance;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyUserId   = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _keyUserName = 'user_name';

  Future<void> saveUserMeta({
    required String id,
    required String role,
    required String name,
  }) async {
    await _storage.write(key: _keyUserId,   value: id);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserName, value: name);
  }

  Future<String?> getUserId()   => _storage.read(key: _keyUserId);
  Future<String?> getUserRole() => _storage.read(key: _keyUserRole);
  Future<String?> getUserName() => _storage.read(key: _keyUserName);

  Future<void> clear() => _storage.deleteAll();
}
