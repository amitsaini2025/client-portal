import 'dart:convert';

import 'package:client/services/stripe_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fcm_service.dart';
import '../models/admin.dart';
import '../models/client.dart';
import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _rememberMeKey = 'remember_me';
  static const String _selectedMatterKey = 'selected_matter_id';
  static const String _selectedMatterNameKey = 'selected_matter_name';
  static const String _clientMatterStageKey = 'client_matter_stage_id';
  static const String _userIdKey = 'user_id';

  // Current user data
  static Client? _currentClient;
  static Admin? _currentAdmin;
  static String? _currentToken;
  static int? _currentUserId;
  static int? _selectedMatterId;
  static String? _selectedMatterName;
  static int? _clientMatterStageId;

  // Getters
  static Client? get currentClient => _currentClient;

  static Admin? get currentAdmin => _currentAdmin;

  static String? get currentToken => _currentToken;

  static int? get currentUserId => _currentUserId;

  static int? get selectedMatterId => _selectedMatterId;

  static String? get selectedMatterName => _selectedMatterName;

  static int? get clientMatterStageId => _clientMatterStageId;

  static bool get isAuthenticated => _currentToken != null;

  static bool get isMatterSelected => _selectedMatterId != null;

  /// Initialize authentication service and load matter
  static Future<void> initialize() async {
    try {
      // Load token
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        _currentToken = token;
        await _loadUserData();
        ApiService.setAuthToken(token);
      }

      // Load selected matter
      final storedMatterId = await _secureStorage.read(key: _selectedMatterKey);
      if (storedMatterId != null) {
        _selectedMatterId = int.tryParse(storedMatterId);
      }

      // Load selected matter name
      final storedMatterName = await _secureStorage.read(
        key: _selectedMatterNameKey,
      );
      if (storedMatterName != null) {
        _selectedMatterName = storedMatterName;
      }

      // Load current user ID
      final storedUserId = await _secureStorage.read(key: _userIdKey);
      if (storedUserId != null) {
        _currentUserId = int.tryParse(storedUserId);
      }
    } catch (e) {
      print('Error initializing AuthService: $e');
    }
  }

  /// Select a matter
  static Future<void> selectMatter({
    required int matterId,
    required String matterName,
  }) async {
    _selectedMatterId = matterId;
    _selectedMatterName = matterName;
    try {
      await _secureStorage.write(
        key: _selectedMatterKey,
        value: matterId.toString(),
      );
      await _secureStorage.write(
        key: _selectedMatterNameKey,
        value: matterName,
      );
    } catch (e) {
      print('Error saving selected matter: $e');
    }
  }

  /// Clear selected matter
  static Future<void> clearSelectedMatter() async {
    _selectedMatterId = null;
    _selectedMatterName = null;
    try {
      await _secureStorage.delete(key: _selectedMatterKey);
      await _secureStorage.delete(key: _selectedMatterNameKey);
    } catch (e) {
      print('Error clearing selected matter: $e');
    }
  }

  /// Check if matter is selected
  static Future<bool> checkMatterSelected() async {
    if (_selectedMatterId != null) return true;

    try {
      final storedId = await _secureStorage.read(key: _selectedMatterKey);
      if (storedId != null) {
        _selectedMatterId = int.tryParse(storedId);
        return true;
      }
    } catch (e) {
      print('Error checking matter selection: $e');
    }
    return false;
  }

  /// Set clientMatterStageId
  static Future<void> setClientMatterStageId(int stageId) async {
    _clientMatterStageId = stageId;
    try {
      await _secureStorage.write(
        key: _clientMatterStageKey,
        value: stageId.toString(),
      );
    } catch (e) {
      print('Error saving client matter stage id: $e');
    }
  }

  /// Clear clientMatterStageId
  static Future<void> clearClientMatterStageId() async {
    _clientMatterStageId = null;
    try {
      await _secureStorage.delete(key: _clientMatterStageKey);
    } catch (e) {
      print('Error clearing client matter stage id: $e');
    }
  }

  /// Login with email/phone and password
  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
  }) async {
    try {
      final response = await ApiService.login(emailOrPhone, password);

      if (response['success'] == true) {
        final token = response['data']['token'];
        final refreshToken = response['data']['refresh_token'];
        final clientData = response['data']['user'];
        final userId = clientData != null ? clientData['id'] as int : null;

        // Store token securely
        await _secureStorage.write(key: _tokenKey, value: token);
        _currentToken = token;
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
        await AuthManager.saveAuthToken(token);
        await AuthManager.saveUserID(userId.toString());

        // Store user data
        if (clientData != null) {
          _currentClient = Client.fromJson(clientData);
          _currentUserId = userId;
          await _saveUserData();
          if (_currentUserId != null) {
            await _secureStorage.write(
              key: _userIdKey,
              value: _currentUserId.toString(),
            );
          }
        }

        // Store remember me preference
        await _secureStorage.write(
          key: _rememberMeKey,
          value: rememberMe.toString(),
        );

        return {
          'success': true,
          'message': 'Login successful',
          'client': _currentClient,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? city,
    String? address,
    DateTime? dob,
    DateTime? weddingAnniversary,
  }) async {
    try {
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Passwords do not match'};
      }

      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
        'city': city,
        'address': address,
        'dob': dob?.toIso8601String(),
        'wedding_anniversary': weddingAnniversary?.toIso8601String(),
      };

      final response = await ApiService.register(userData);

      if (response['success'] == true) {
        return {
          'success': true,
          'message':
              'Registration successful. Please check your email for verification.',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      // Call API logout if token exists
      if (_currentToken != null) {
        try {
          final fcmService = FCMService();
          String? fcmToken = await fcmService.getToken();
          if (fcmToken != null) {
            await ApiService.unregisterFcmToken(fcmToken);
          }
          await ApiService.logout();
        } catch (e) {
          print('Logout API call failed: $e');
        }
      }

      // Clear local storage
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userDataKey);
      await _secureStorage.delete(key: _selectedMatterKey);
      await _secureStorage.delete(key: _userIdKey);

      // Clear memory
      _currentToken = null;
      _currentClient = null;
      _currentAdmin = null;
      _currentUserId = null;
      _selectedMatterId = null;

      ApiService.clearAuthToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Save user data to secure storage
  static Future<void> _saveUserData() async {
    if (_currentClient != null) {
      await _secureStorage.write(
        key: _userDataKey,
        value: json.encode(_currentClient!.toJson()),
      );
    }
  }

  /// Load user data from secure storage
  static Future<void> _loadUserData() async {
    try {
      final userData = await _secureStorage.read(key: _userDataKey);
      if (userData != null) {
        final data = json.decode(userData);
        _currentClient = Client.fromJson(data);
        _currentUserId = data['id'];
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric authentication
  static Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication
  static Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiService.forgotPassword(email);

      if (response['success'] == true) {
        final message = response['message'];
        return {'success': true, 'message': message};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to send reset link',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Passwords do not match'};
      }

      final response = await ApiService.resetPassword(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Password reset successful'};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Refresh authentication token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await ApiService.refreshToken();

      if (response['success'] == true) {
        final newToken = response['data']['token'];
        await _secureStorage.write(key: _tokenKey, value: newToken);
        _currentToken = newToken;
        await AuthManager.saveAuthToken(newToken);

        // Update API service with new token
        ApiService.setAuthToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  /// Clear all stored data
  static Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear memory
    _currentToken = null;
    _currentClient = null;
    _currentAdmin = null;
    _currentUserId = null;
    _selectedMatterId = null;
    _selectedMatterName = null;
    _clientMatterStageId = null;

    ApiService.clearAuthToken();
  }
}
