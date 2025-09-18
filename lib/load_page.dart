// lib/load_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

class LoadPage extends StatefulWidget {
  const LoadPage({Key? key}) : super(key: key);

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  String? _jsonPath;
  List<dynamic> _ayahs = [];
  final TextEditingController _textController = TextEditingController();

  // 1️⃣ Create a test JSON in app storage
  Future<void> _createTestJson() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/test_quran.json';

    List<Map<String, dynamic>> initialData = [
      {
        "surah": 1,
        "ayah_number": 1,
        "text": "In the name of Allah, the Most Gracious",
      },
      {
        "surah": 1,
        "ayah_number": 2,
        "text": "Praise be to Allah, Lord of the worlds",
      },
    ];

    String content = const JsonEncoder.withIndent('  ').convert(initialData);
    await File(path).writeAsString(content);

    setState(() {
      _jsonPath = path;
      _ayahs = initialData;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Test JSON created at: $path')));
  }

  // 2️⃣ Pick a JSON file from storage
  Future<void> _pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      String content = await File(path).readAsString();

      try {
        List<dynamic> data = jsonDecode(content);
        setState(() {
          _jsonPath = path;
          _ayahs = data;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid JSON')));
      }
    }
  }

  // 3️⃣ Save / Overwrite JSON using SAF
  Future<void> _saveAyah() async {
    if (_textController.text.isEmpty) return;

    // Add new ayah in memory
    _ayahs.add({
      "surah": 1,
      "ayah_number": _ayahs.length + 1,
      "text": _textController.text,
    });

    // Convert JSON to bytes
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(_ayahs)),
    );

    try {
      // First let user pick a directory (SAF)
      if (!await FlutterFileDialog.isPickDirectorySupported()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Directory picking not supported on this device."),
          ),
        );
        return;
      }

      final pickedDir = await FlutterFileDialog.pickDirectory();

      if (pickedDir != null) {
        // Save into picked directory
        final savedPath = await FlutterFileDialog.saveFileToDirectory(
          directory: pickedDir,
          data: bytes,
          mimeType: "application/json",
          fileName: "quran.json",
          replace: true,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Saved at: $savedPath")));

        setState(() {
          _textController.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Save cancelled.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran Recall')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _createTestJson,
              child: const Text('Create Test JSON'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickJsonFile,
              child: const Text('Pick JSON File'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'New Ayah text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAyah,
              child: const Text('Save / Overwrite JSON'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _ayahs.isEmpty
                      ? const Center(child: Text('No JSON loaded yet.'))
                      : ListView.builder(
                        itemCount: _ayahs.length,
                        itemBuilder: (context, index) {
                          var ayah = _ayahs[index];
                          return ListTile(
                            title: Text(
                              'Ayah ${ayah['ayah_number']}: ${ayah['text']}',
                            ),
                            subtitle: Text('Surah ${ayah['surah']}'),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
