import 'package:supabase_flutter/supabase_flutter.dart';

class SuperAdminService {
  static final SuperAdminService _instance = SuperAdminService._internal();
  factory SuperAdminService() => _instance;
  SuperAdminService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Get total number of admins from database
  Future<int> getTotalAdmins() async {
    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('role', 'ADMIN');
      
      return response.length;
    } catch (e) {
      print('Error getting total admins: $e');
      return 0;
    }
  }

  /// Get total number of users from database
  Future<int> getTotalUsers() async {
    try {
      final response = await _client
          .from('users')
          .select('id');
      
      return response.length;
    } catch (e) {
      print('Error getting total users: $e');
      return 0;
    }
  }

  /// Get total number of parking lots from database
  Future<int> getTotalParkingLots() async {
    try {
      final response = await _client
          .from('parking_lots')
          .select('id');
      
      return response.length;
    } catch (e) {
      print('Error getting total parking lots: $e');
      return 0;
    }
  }

  /// Get total number of parking spots from database
  Future<int> getTotalParkingSpots() async {
    try {
      final response = await _client
          .from('parking_spots')
          .select('id');
      
      return response.length;
    } catch (e) {
      print('Error getting total parking spots: $e');
      return 0;
    }
  }

  /// Get total number of reservations from database
  Future<int> getTotalReservations() async {
    try {
      final response = await _client
          .from('reservations')
          .select('id');
      
      return response.length;
    } catch (e) {
      print('Error getting total reservations: $e');
      return 0;
    }
  }

  /// Get all admins from database
  Future<List<Map<String, dynamic>>> getAdmins() async {
    try {
      print('DEBUG: SuperAdminService: Fetching admins from database...');
      final response = await _client
          .from('users')
          .select('*')
          .eq('role', 'ADMIN')
          .order('created_at', ascending: false);
      
      print('DEBUG: SuperAdminService: Raw response: $response');
      print('DEBUG: SuperAdminService: Response type: ${response.runtimeType}');
      
      final adminsList = List<Map<String, dynamic>>.from(response);
      print('DEBUG: SuperAdminService: Converted to list: ${adminsList.length} items');
      
      return adminsList;
    } catch (e, stackTrace) {
      print('DEBUG: SuperAdminService: Error getting admins: $e');
      print('DEBUG: SuperAdminService: Stack trace: $stackTrace');
      return [];
    }
  }

  /// Create a new admin user
  Future<bool> createAdmin({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      print('DEBUG: Creating admin with email: $email');
      
      // Create user in Supabase Auth
      final authResponse = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
          userMetadata: {
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
            'role': 'ADMIN',
          },
        ),
      );

      if (authResponse.user == null) {
        print('DEBUG: Failed to create auth user: ${authResponse}');
        throw Exception('Failed to create auth user');
      }

      print('DEBUG: Auth user created with ID: ${authResponse.user!.id}');

      // Create user record in public users table
      final userData = {
        'id': authResponse.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': 'ADMIN',
        'verification_status': 'VERIFIED',
        'average_rating': 0.0,
        'total_reviews': 0,
      };

      print('DEBUG: Inserting user data: $userData');
      
      final insertResponse = await _client.from('users').insert(userData);
      print('DEBUG: Insert response: $insertResponse');

      return true;
    } catch (e, stackTrace) {
      print('DEBUG: Error creating admin: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return false;
    }
  }

  /// Delete an admin user
  Future<bool> deleteAdmin(String userId) async {
    try {
      // Delete from public users table
      await _client.from('users').delete().eq('id', userId);
      
      // Delete from Supabase Auth
      await _client.auth.admin.deleteUser(userId);
      
      return true;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }
}
