// lib/load_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class LoadPage extends StatefulWidget {
  const LoadPage({Key? key}) : super(key: key);

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  static const platform = MethodChannel('quran_recall/files');

  List<dynamic> _ayahs = [];
  String? _pickedFileUri; // SAF URI
  final TextEditingController _textController = TextEditingController();

  // Pick file via SAF
  Future<void> _pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true, // important: get bytes to read content
    );

    if (result != null && result.files.isNotEmpty) {
      _pickedFileUri = result.files.first.identifier; // This is SAF URI if using SAF picker

      final content = result.files.first.bytes != null
          ? utf8.decode(result.files.first.bytes!)
          : '';

      try {
        List<dynamic> data = content.isNotEmpty ? jsonDecode(content) : [];
        setState(() {
          _ayahs = data;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid JSON')),
        );
      }
    }
  }

  // Save / overwrite using SAF URI
  Future<void> _saveAyah() async {
    if (_pickedFileUri == null || _textController.text.isEmpty) return;

    _ayahs.add({
      "surah": 1,
      "ayah_number": _ayahs.length + 1,
      "text": _textController.text,
    });

    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(_ayahs));

    try {
      final result = await platform.invokeMethod('overwriteFile', {
        'uri': _pickedFileUri,
        'data': bytes,
      });

      setState(() {
        _ayahs;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File overwritten: $result')),
      );

      _textController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to overwrite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran Recall')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickJsonFile,
              child: const Text('Pick JSON File'),
            ),
            const SizedBox(height: 10),
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
              child: _ayahs.isEmpty
                  ? const Center(child: Text('No JSON loaded yet.'))
                  : ListView.builder(
                      itemCount: _ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = _ayahs[index];
                        return ListTile(
                          title: Text('Ayah ${ayah['ayah_number']}: ${ayah['text']}'),
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
