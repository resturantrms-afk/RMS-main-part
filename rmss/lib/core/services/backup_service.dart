import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

class BackupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Export data to a JSON file and trigger a download.
  static Future<void> exportBackup() async {
    final Map<String, dynamic> backupData = {};

    // 1. Fetch Menu Items
    final menuSnapshot = await _firestore.collection('menu_items').get();
    backupData['menu_items'] = menuSnapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id; // Include document ID
      return data;
    }).toList();

    // 2. Fetch Tables
    final tablesSnapshot = await _firestore.collection('tables').get();
    backupData['tables'] = tablesSnapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return data;
    }).toList();

    // 3. Fetch Orders
    final ordersSnapshot = await _firestore.collection('orders').get();
    backupData['orders'] = ordersSnapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      // Convert timestamps to strings for JSON serialization
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] =
            (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] =
            (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
      }
      return data;
    }).toList();

    // 4. Fetch Payments
    final paymentsSnapshot = await _firestore.collection('payments').get();
    backupData['payments'] = paymentsSnapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] =
            (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] =
            (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
      }
      return data;
    }).toList();

    // Convert to JSON String
    final jsonString = jsonEncode(backupData);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    // Save File
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    await FileSaver.instance.saveFile(
      name: 'RMS_Backup_$dateStr',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }

  /// Import data from a JSON file and restore it (ignoring existing items)
  static Future<Map<String, int>> restoreBackup() async {
    // 1. Pick file
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) {
      return {'status': 0}; // Cancelled
    }

    final file = result.files.single;
    String jsonString;

    if (file.bytes != null) {
      jsonString = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      jsonString = await File(file.path!).readAsString();
    } else {
      throw Exception('Could not read file data.');
    }

    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    int itemsAdded = 0;
    int itemsSkipped = 0;

    // Helper to process a collection
    Future<void> processCollection(String collectionName) async {
      if (!backupData.containsKey(collectionName)) return;

      final List<dynamic> items = backupData[collectionName];
      final collectionRef = _firestore.collection(collectionName);

      for (var item in items) {
        final data = Map<String, dynamic>.from(item);
        final id = data['id'];

        // Restore Timestamps
        if (data.containsKey('createdAt') && data['createdAt'] is int) {
          data['createdAt'] = Timestamp.fromMillisecondsSinceEpoch(
            data['createdAt'],
          );
        }
        if (data.containsKey('updatedAt') && data['updatedAt'] is int) {
          data['updatedAt'] = Timestamp.fromMillisecondsSinceEpoch(
            data['updatedAt'],
          );
        }

        data.remove('id'); // Remove id from fields before setting

        if (id != null && id.toString().isNotEmpty) {
          final docSnap = await collectionRef.doc(id).get();
          if (!docSnap.exists) {
            await collectionRef.doc(id).set(data);
            itemsAdded++;
          } else {
            itemsSkipped++;
          }
        } else {
          // If no ID (which shouldn't happen based on our export), we skip to be safe against duplicates
          itemsSkipped++;
        }
      }
    }

    // Process only allowed collections (Ignoring Users)
    await processCollection('menu_items');
    await processCollection('tables');
    await processCollection('orders');
    await processCollection('payments');

    return {'status': 1, 'added': itemsAdded, 'skipped': itemsSkipped};
  }
}
