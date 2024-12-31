import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabase {
  // Get the local file for storing JSON data
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  // Read data from the file
  Future<List<Map<String, dynamic>>> readData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        return List<Map<String, dynamic>>.from(jsonDecode(contents));
      }
    } catch (e) {
      print("Error reading file: $e");
    }
    return [];
  }

  // Write data to the file
  Future<void> writeData(List<Map<String, dynamic>> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  // Add a new post to the data
  Future<void> addPost(Map<String, dynamic> post) async {
    final data = await readData();
    data.add(post);
    await writeData(data);
  }

  // Delete a post by index
  Future<void> deletePost(int index) async {
    final data = await readData();
    data.removeAt(index);
    await writeData(data);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDatabase db = LocalDatabase();
  final TextEditingController titleController = TextEditingController();
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final data = await db.readData();
    setState(() {
      posts = data;
    });
  }

  Future<void> _addPost() async {
    if (titleController.text.isNotEmpty) {
      await db.addPost({'title': titleController.text});
      titleController.clear();
      _loadPosts();
    }
  }

  Future<void> _deletePost(int index) async {
    await db.deletePost(index);
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Local JSON Example")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: "Enter post title"),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addPost,
                  child: Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(posts[index]['title']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePost(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
