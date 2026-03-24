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
      // IMPORTANT:
      // auth.admin.createUser() requires service-role privileges and will fail
      // from the browser client with 401 no_authorization.
      // We use regular signUp from client side.
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': 'ADMIN',
        },
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Failed to create auth user');
      }

      // Create user record in public users table.
      // Try with UUID id first (for projects that use UUID PK),
      // then fallback without id (for SERIAL/INT PK).
      final userDataWithId = {
        'id': authUser.id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': 'ADMIN',
        'verification_status': 'VERIFIED',
        'average_rating': 0.0,
        'total_reviews': 0,
      };
      final userDataWithoutId = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': 'ADMIN',
        'verification_status': 'VERIFIED',
        'average_rating': 0.0,
        'total_reviews': 0,
      };

      try {
        await _client.from('users').insert(userDataWithId);
      } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('invalid input syntax for type integer') ||
            msg.contains('22p02')) {
          try {
            await _client.from('users').insert(userDataWithoutId);
          } catch (inner) {
            final innerMsg = inner.toString().toLowerCase();
            // In some setups, a DB trigger inserts the user row after signUp.
            // If our explicit insert hits uniqueness constraints, consider it success.
            if (innerMsg.contains('duplicate key') ||
                innerMsg.contains('23505') ||
                innerMsg.contains('users_email_key') ||
                innerMsg.contains('users_phone_key') ||
                innerMsg.contains('users_pkey')) {
              return true;
            }
            rethrow;
          }
        } else if (msg.contains('duplicate key') ||
            msg.contains('23505') ||
            msg.contains('users_email_key') ||
            msg.contains('users_phone_key') ||
            msg.contains('users_pkey')) {
          return true;
        } else {
          rethrow;
        }
      }

      return true;
    } catch (e, stackTrace) {
      print('DEBUG: Error creating admin: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return false;
    }
  }

  /// Delete an admin user
  Future<bool> deleteAdmin(dynamic userId) async {
    try {
      final deletedRows = await _client
          .from('users')
          .delete()
          .eq('id', userId)
          .select('id');

      final deleted = deletedRows is List && deletedRows.isNotEmpty;
      if (!deleted) return false;

      // Optional best-effort cleanup in Auth when id is UUID.
      // On client-side this usually fails with 401 (service-role needed),
      // but the admin is already deleted from app DB, so we still return success.
      final idString = userId.toString();
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      ).hasMatch(idString);
      if (isUuid) {
        try {
          await _client.auth.admin.deleteUser(idString);
        } catch (_) {}
      }

      return true;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }
}
