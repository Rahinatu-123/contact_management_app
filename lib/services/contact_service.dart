import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactService {
  final String baseUrl = 'https://apps.ashesi.edu.gh/contactmgt/actions';

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_all_contact_mob'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Handle case where response is a List
      if (decodedData is List) {
        return List<Map<String, dynamic>>.from(decodedData);
      }
      // Handle case where response is a Map
      else if (decodedData is Map && decodedData.containsKey('data')) {
        final List<dynamic> data = decodedData['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      // Return empty list if response is invalid
      return [];
    } else {
      throw Exception('Failed to load contacts: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getSingleContact(int contactId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_a_contact_mob?contid=$contactId'));

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Handle case where response is a List
      if (decodedData is List) {
        return decodedData.isNotEmpty ? Map<String, dynamic>.from(decodedData[0]) : {};
      }
      // Handle case where response is a Map
      else if (decodedData is Map) {
        return Map<String, dynamic>.from(decodedData);
      }
      // Return empty map if response is invalid
      return {};
    } else {
      throw Exception('Failed to load contact');
    }
  }

  Future<String> addContact({required String fullName, required String phoneNumber}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_contact_mob'),
      body: {'ufullname': fullName, 'uphonename': phoneNumber},
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      return 'Failed to add contact: ${response.statusCode}';
    }
  }

  Future<String> updateContact({required int id, required String fullName, required String phoneNumber}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_contact'),
      body: {'cname': fullName, 'cnum': phoneNumber, 'cid': id.toString()},
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      return 'Failed to update contact: ${response.statusCode}';
    }
  }

  Future<bool> deleteContact(int contactId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_contact'),
      body: {'cid': contactId.toString()},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}