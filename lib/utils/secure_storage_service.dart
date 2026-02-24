import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = const FlutterSecureStorage();

  static Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'remember_me', value: rememberMe.toString()); // still stored as string internally
  }

  static Future<Map<String, dynamic>> loadCredentials() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');
    final rememberStr = await _storage.read(key: 'remember_me');

    final remember = rememberStr == 'true'; // convert string to bool

    return {
      'email': email,
      'password': password,
      'remember': remember,
    };
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'remember_me');
  }
}