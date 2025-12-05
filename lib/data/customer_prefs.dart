import 'package:shared_preferences/shared_preferences.dart';

/// Handles saving and loading the last entered customer fields.
class CustomerPrefs {
  static const _keyFirstName = 'last_customer_first_name';
  static const _keyLastName = 'last_customer_last_name';
  static const _keyAddress = 'last_customer_address';
  static const _keyDob = 'last_customer_dob';
  static const _keyLicense = 'last_customer_license';

  /// Saves customer fields so they can be reused later.
  static Future<void> saveLastCustomer({
    required String firstName,
    required String lastName,
    required String address,
    required String dateOfBirth,
    required String driverLicense,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyAddress, address);
    await prefs.setString(_keyDob, dateOfBirth);
    await prefs.setString(_keyLicense, driverLicense);
  }

  /// Loads the most recently saved customer fields, or null if none exist.
  static Future<Map<String, String>?> loadLastCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString(_keyFirstName);
    final last = prefs.getString(_keyLastName);
    final addr = prefs.getString(_keyAddress);
    final dob = prefs.getString(_keyDob);
    final lic = prefs.getString(_keyLicense);

    if (first == null || last == null || addr == null || dob == null || lic == null) {
      return null;
    }

    return {
      'firstName': first,
      'lastName': last,
      'address': addr,
      'dateOfBirth': dob,
      'driverLicense': lic,
    };
  }
}
