import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tutorial_drive_flutter/app/src/core/services/drive_service.dart';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  final DriveService _driveService = DriveService();
  bool _isLoading = false;
  List<drive.File> _folders = [];
  String? _selectedFolderId;

  Future<void> _fetchFolders() async {
    try {
      final folders = await _driveService.getFoldersInParent();
      if (mounted) {
        setState(() {
          _folders = folders;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching folders: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    await _fetchFolders();

    if (_folders.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No folders available.')),
        );
      }
      return;
    }

    final rootContext = context; // Guarda el contexto principal

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _folders.map((folder) {
            return ListTile(
              title: Text(folder.name ?? 'Unnamed Folder'),
              onTap: () async {
                Navigator.pop(context); // Cierra el modal primero

                _selectedFolderId = folder.id;

                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null && result.files.single.path != null) {
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  final file = File(result.files.single.path!);

                  try {
                    await _driveService.uploadFileToDrive(file, _selectedFolderId!);
                    if (mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(content: Text('File uploaded successfully: ${file.path.split('/').last}')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(content: Text('Error uploading file: $e')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pickAndUploadFile,
                    child: const Text('Select and Upload PDF'),
                  ),
          ],
        ),
      ),
    );
  }
}
