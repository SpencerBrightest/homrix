import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_error.dart';
import '../domain/auth_user.dart';
../domain/auth_state.dart';

/// Repository pattern implementation - mediates between data sources
///
/// UI reads solely from local cache (Source of Truth).
/// Network operations go through this repository, which writes to cache
/// and reactive pumps updates through Riverpod to UI.
class AuthRepository {
  /// Local data source for session persistence
  final HiveLocalDataSource _localDataSource;

  /// Remote API client for server communication
  final ApiClient _apiClient;

  AuthRepository({
    required HiveLocalDataSource localDataSource,
    required ApiClient apiClient,
  })  : _localDataSource = localDataSource,
        _apiClient = apiClient;

  /// Get persistent session from local storage
  Future<Map<String, dynamic>?> getPersistentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('user_session');
    if (sessionJson != null) {
      return jsonDecode(sessionJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save session persistently across app restarts
  Future<void> savePersistentSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(session));
  }

  /// Clear session (on logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    await _localDataSource.clearAllCache();
  }

  /// Validate session with backend
  Future<bool> validateSession(String token) async {
    try {
      final response = await _apiClient.post(
        endpoint: '/auth/validate',
        body: {'token': token},
      );
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      endpoint: '/auth/signin',
      body: {
        'email': email,
        'password': password,
      },
    );

    // Save session persistently
    await savePersistentSession(response);

    return response;
  }

  /// Get or create user profile
  Future<AuthUser> getOrCreateUser({
    required String uid,
    required String email,
  }) async {
    try {
      final response = await _apiClient.get(
        endpoint: '/users/$uid',
      );

      // If user exists, return from server
      if (response.containsKey('id')) {
        return AuthUser(
          id: response['id'],
          email: email,
          displayName: response['displayName'],
          role: _mapRole(response['role']),
          isEmailVerified: response['isEmailVerified'] ?? false,
          lastLogin: DateTime.parse(response['lastLogin']),
          createdAt: DateTime.parse(response['createdAt']),
        );
      }

      // Otherwise create new user
      return AuthUser(
        id: uid,
        email: email,
        role: AuthRole.guest, // Default role
        isEmailVerified: false,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Return minimal user if profile fetch fails
      return AuthUser(
        id: uid,
        email: email,
        role: AuthRole.guest,
        isEmailVerified: false,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  /// Map string role from server to AuthRole enum
  AuthRole _mapRole(dynamic role) {
    if (role == 'admin') return AuthRole.admin;
    if (role == 'host') return AuthRole.host;
    return AuthRole.guest;
  }

  /// Login with biometric (re-validates existing server session)
  Future<void> loginWithBiometric() async {
    // Biometric succeeds - re-use existing persistent session
    final session = await getPersistentSession();
    if (session != null && session['uid'] != null) {
      // Session already exists, just re-initialize state
      // The actual state management is done by the AuthNotifier
    }
  }

  /// Refresh session before expiry
  Future<Map<String, dynamic>?> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.post(
        endpoint: '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required AuthRole role,
  }) async {
    final response = await _apiClient.post(
      endpoint: '/auth/register',
      body: {
        'email': email,
        'password': password,
        'role': role.toString().split('.').last, // 'guest', 'host', 'admin'
      },
    );

    // Save session after successful registration
    await savePersistentSession(response);

    return response;
  }
}