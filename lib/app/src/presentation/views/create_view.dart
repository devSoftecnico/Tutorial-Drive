import 'package:flutter/material.dart';
import 'package:tutorial_drive_flutter/app/src/core/services/drive_service.dart';

class CreateView extends StatefulWidget {
  const CreateView({super.key});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  final DriveService _driveService = DriveService();
  final TextEditingController _folderNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createFolder() async {
    if (_folderNameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final folder = await _driveService.createFolder(_folderNameController.text);
      if (folder != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "${folder.name}" created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create folder.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _folderNameController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _createFolder,
                  child: const Text('Create Folder'),
                ),
        ],
      ),
    );
  }
}
