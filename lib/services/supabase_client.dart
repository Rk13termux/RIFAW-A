import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class SupabaseClientService {
  static SupabaseClientService? _instance;
  static SupabaseClient? _client;

  SupabaseClientService._();

  static SupabaseClientService get instance {
    _instance ??= SupabaseClientService._();
    return _instance!;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado. Llama a initialize() primero.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Auth helpers
  User? get currentUser => _client?.auth.currentUser;
  
  String? get currentUserId => _client?.auth.currentUser?.id;
  
  bool get isAuthenticated => _client?.auth.currentUser != null;
  
  Stream<AuthState> get authStateChanges => 
      _client!.auth.onAuthStateChange;

  // Sign in anónimo (para probar sin login)
  Future<AuthResponse> signInAnonymously() async {
    return await _client!.auth.signInAnonymously();
  }

  // Sign in con email/password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client!.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client!.auth.signOut();
  }

  // Storage helpers
  Future<String> uploadImage(String bucket, String path, List<int> bytes) async {
    await _client!.storage.from(bucket).uploadBinary(path, bytes);
    return _client!.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteImage(String bucket, String path) async {
    await _client!.storage.from(bucket).remove([path]);
  }
}
