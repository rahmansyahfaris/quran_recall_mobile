// lib/load_page.dart
import 'dart:convert'; // for jsonDecode
import 'dart:io'; // for File
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // for picking files

class LoadPage extends StatefulWidget {
  const LoadPage({Key? key}) : super(key: key); // add const and key
  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  String? _jsonContent; // stores raw JSON string

  // Function to pick a JSON file
  Future<void> _importJson() async {
    // Open file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      File file = File(path);

      // Read file as string
      String content = await file.readAsString();

      // Optional: Parse JSON to check validity
      try {
        var parsed = jsonDecode(content); // just to check format
        print(parsed); // debug print
      } catch (e) {
        print("Invalid JSON format");
      }

      // Update state to display content
      setState(() {
        _jsonContent = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load JSON File'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _importJson,
              child: Text('Import JSON'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _jsonContent ?? 'No JSON loaded yet.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
