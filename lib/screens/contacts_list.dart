import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../services/contact_service.dart';


class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ContactsListScreenState createState() => ContactsListScreenState();
}

class ContactsListScreenState extends State<ContactsListScreen> {
  final Logger _logger = Logger();
  final ContactService _contactService = ContactService();
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final contacts = await _contactService.getAllContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Failed to load contacts: $e';
      });
      _logger.e('Failed to load contacts: $e');
    }
  }

  Future<void> _deleteContact(int contactId) async {
    try {
      final success = await _contactService.deleteContact(contactId);
      if (success) {
        setState(() {
          _contacts.removeWhere((contact) => contact['pid'] == contactId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete contact'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _logger.e('Failed to delete contact');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _logger.e('Failed to delete contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchContacts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _fetchContacts,
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        title: Text(contact['pname']),
                        subtitle: Text(contact['pphone']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/editContact',
                                  arguments: {'contactId': contact['pid']},
                                ).then((_) => _fetchContacts());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteContact(contact['pid']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}