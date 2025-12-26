/// Contact Picker Service
/// خدمة اختيار جهات الاتصال من الهاتف
library;

import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

/// Service for picking contacts from device
class ContactPickerService {
  ContactPickerService._();
  static final ContactPickerService instance = ContactPickerService._();

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  /// Pick a phone number from contacts
  /// Returns the phone number or null if cancelled
  Future<String?> pickPhoneNumber() async {
    try {
      // Open native contact picker with phone number selection
      final contact = await _contactPicker.selectPhoneNumber();

      if (contact == null) return null;

      // Extract phone number
      final phoneNumbers = contact.phoneNumbers;

      if (phoneNumbers != null && phoneNumbers.isNotEmpty) {
        // Get first phone number and clean it
        final phone = phoneNumbers.first;
        return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      }

      return null;
    } catch (e) {
      // User cancelled or error occurred
      return null;
    }
  }

  /// Pick a full contact (name + phone)
  /// Returns a map with 'name' and 'phone' or null if cancelled
  Future<Map<String, String>?> pickContact() async {
    try {
      final contact = await _contactPicker.selectPhoneNumber();

      if (contact == null) return null;

      final name = contact.fullName ?? '';
      final phoneNumbers = contact.phoneNumbers;

      String phone = '';
      if (phoneNumbers != null && phoneNumbers.isNotEmpty) {
        phone = phoneNumbers.first.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      }

      if (name.isNotEmpty || phone.isNotEmpty) {
        return {'name': name, 'phone': phone};
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
