import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Question Answer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> qaList = [];
  List<Map<String, dynamic>> filteredList = [];

  String selectedFilePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyceum of Wisdom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  // Filter the qaList based on the entered question
                  filteredList = filterQAList(value);
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your question',
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                // Allow the user to select a JSON file
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null){
                  String? filePath = result.files.first.path;
                  if (filePath != null) {
                    setState(() {
                      selectedFilePath = filePath;
                      // Read the JSON file and parse its contents
                      qaList = loadQAList(filePath);
                    });
                  }
                }

              },
              child: const Text('Select JSON File'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredList[index]['question'] ?? ''),
                    subtitle: Text(filteredList[index]['response'] ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> filterQAList(String question) {
    String normalizedQuestion = removeAccentsAndSpecialChars(question.toLowerCase());

    filteredList = [];

    if (normalizedQuestion.isEmpty) {
      filteredList = List.from(qaList);
    } else {
      filteredList = qaList
          .where((qa) =>
          removeAccentsAndSpecialChars(qa['question']!.toLowerCase())
              .contains(normalizedQuestion))
          .toList();
    }

    return filteredList;
  }

  String removeAccentsAndSpecialChars(String input) {
    final normalizedChars = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ñ': 'n',
    };

    final normalizedString = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final normalizedChar = normalizedChars[char];
      if (normalizedChar != null) {
        normalizedString.write(normalizedChar);
      } else if (RegExp(r'[a-zA-Z0-9\s]').hasMatch(char)) {
        normalizedString.write(char);
      }
    }

    return normalizedString.toString();
  }

  List<Map<String, dynamic>> loadQAList(String filePath) {
    File file = File(filePath);
    String contents = file.readAsStringSync();
    List<dynamic> jsonList = json.decode(contents);
    return jsonList.map((item) {
      return {
        'question': item['question'] ?? '',
        'response': item['response'] ?? '',
      };
    }).toList();
  }
}
