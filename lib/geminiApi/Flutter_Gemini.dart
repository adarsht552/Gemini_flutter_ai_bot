import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final gemini = Gemini.instance;
  final Uuid uuid = Uuid();
  File? _selectedImage;
  File? _selectedFile;

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    _textController.clear();
    final userMessage = types.TextMessage(
      author: types.User(id: 'user'),
      id: uuid.v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    String botResponse = '';
    if (_selectedImage != null) {
      final response = await gemini.textAndImage(
        text: text,
        images: [_selectedImage!.readAsBytesSync()],
      );
      botResponse = response?.output as String ?? 'Error getting response';

      _selectedImage = null; // Clear the image after processing
    } else if (_selectedFile != null) {
      // Process the file (you may need to implement file processing logic)
      botResponse = 'File processing not implemented yet';
      _selectedFile = null; // Clear the file after processing
    } else {
      final response = await gemini.text(text);
      botResponse = response?.output ?? 'Error getting response';
    }

    final botMessage = types.TextMessage(
      author: types.User(id: 'bot'),
      id: uuid.v4(),
      text: botResponse,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _messages.insert(0, types.TextMessage(
            author: types.User(id: 'system'),
            id: uuid.v4(),
            text: 'Image selected: ${_selectedImage!.path}',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _messages.insert(0, types.TextMessage(
            author: types.User(id: 'system'),
            id: uuid.v4(),
            text: 'File selected: ${_selectedFile!.path}',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        });
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chat')),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: (partialText) {
                _handleSubmitted(partialText.text);
              },
              user: const types.User(id: 'user'),
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickFile,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(hintText: "Send a message"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}
