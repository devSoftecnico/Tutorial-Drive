import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tutorial_drive_flutter/app/src/core/services/drive_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class DeleteView extends StatefulWidget {
  const DeleteView({super.key});

  @override
  State<DeleteView> createState() => _DeleteViewState();
}

class _DeleteViewState extends State<DeleteView> {
  final DriveService _driveService = DriveService();
  List<drive.File> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    try {
      final folders = await _driveService.getFoldersInParent();
      setState(() {
        _folders = folders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching folders: $e')),
      );
    }
  }

  Future<void> _deleteFolder(String folderId) async {
    try {
      await _driveService.deleteFolder(folderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder deleted successfully.')),
      );
      _fetchFolders(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting folder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? const Center(child: Text('No folders found.'))
              : ListView.builder(
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    return Slidable(
                      key: ValueKey(folder.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => _deleteFolder(folder.id!),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(folder.name ?? 'Unnamed Folder'),
                        subtitle: Text('ID: ${folder.id}'),
                        onTap: () {
                          if (kDebugMode) {
                            print('Selected folder: ${folder.name}');
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
