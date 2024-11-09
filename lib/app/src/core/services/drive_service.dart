import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class DriveService {
  final String _credentialsPath = 'lib/assets/credentials.json';
  final String parentFolderId = '1nhT1NXzTpXxjl4DcwkXWsCZcmkVM3TxE';

  Future<drive.DriveApi> connect() async {
    try {
      final credentialsContent = await rootBundle.loadString(_credentialsPath);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(credentialsContent));

      final authClient = await clientViaServiceAccount(
        accountCredentials,
        [drive.DriveApi.driveScope],
      );

      return drive.DriveApi(authClient);
    } catch (e) {
      if (kDebugMode) {
        print('Error al conectar con Google Drive: $e');
      }
      rethrow;
    }
  }

  Future<List<drive.File>> getFoldersInParent() async {
    final driveApi = await connect();
    final query = "'$parentFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final fileList = await driveApi.files.list(q: query, spaces: 'drive');

    return fileList.files ?? [];
  }

  Future<drive.File?> getFolderById(String folderId) async {
    final driveApi = await connect();
    try {
      final folder = await driveApi.files.get(
        folderId,
        $fields: 'id, name, mimeType',
      );
      if (folder is drive.File) {
        return folder;
      } else {
        throw Exception('Unexpected response type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving folder by ID: $e');
      }
      return null;
    }
  }

  Future<drive.File?> createFolder(String name) async {
    final driveApi = await connect();
    final folderMetadata = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentFolderId];

    try {
      final folder = await driveApi.files.create(folderMetadata);
      return folder;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating folder: $e');
      }
      return null;
    }
  }

  Future<bool> updateFolderName(String folderId, String newName) async {
    final driveApi = await connect();
    final updateMetadata = drive.File()..name = newName;

    try {
      await driveApi.files.update(updateMetadata, folderId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating folder name: $e');
      }
      return false;
    }
  }

  Future<bool> deleteFolder(String folderId) async {
    final driveApi = await connect();

    try {
      await driveApi.files.delete(folderId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting folder: $e');
      }
      return false;
    }
  }

  Future<void> uploadFileToDrive(File file, [String? folderId]) async {
    final driveApi = await connect();
    final media = drive.Media(file.openRead(), file.lengthSync());
    final fileMetadata = drive.File()
      ..name = file.uri.pathSegments.last
      ..parents = folderId != null ? [folderId] : [parentFolderId]; // Usa el ID de la carpeta si se proporciona

    try {
      await driveApi.files.create(fileMetadata, uploadMedia: media);
      if (kDebugMode) {
        print('File uploaded successfully: ${file.uri.pathSegments.last}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }
}
