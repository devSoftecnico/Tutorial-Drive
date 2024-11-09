import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tutorial_drive_flutter/app/src/core/services/drive_service.dart';

class FolderView extends StatelessWidget {
  final DriveService driveService = DriveService();

  FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<drive.File>>(
      future: driveService.getFoldersInParent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No folders found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final folder = snapshot.data![index];
              return ListTile(
                title: Text(folder.name ?? 'Unnamed Folder'),
                subtitle: Text('ID: ${folder.id}'),
              );
            },
          );
        }
      },
    );
  }
}
