import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = "OPENROUTER_API_KEY"; // Replace with your OpenRouter API key
  final String _model = "AI";
  bool _isLoading = false;

  List<Map<String, String>> messages = [];

  Future<void> getResponse(String query) async {
    setState(() {
      messages.add({"user": query});
      _isLoading = true;
    });

    // Check Firestore for stored response
    String? storedResponse = await _checkFirebaseForResponse(query);

    if (storedResponse != null) {
      setState(() {
        messages.add({"bot": storedResponse});
        _isLoading = false;
      });
    } else {
      // No stored response, call AI API
      String aiResponse = await _getAIResponse(query);

      if (aiResponse.isNotEmpty) {
        // Save new response to Firestore
        await _saveToFirebase(query, aiResponse);

        setState(() {
          messages.add({"bot": aiResponse});
          _isLoading = false;
        });
      }
    }
  }

  // Function to check Firestore for a matching query
  Future<String?> _checkFirebaseForResponse(String query) async {
    try {
      final normalizedQuery = query.toLowerCase().trim();
      final snapshot = await _firestore.collection('chat_responses').get();

      for (var doc in snapshot.docs) {
        if (doc['user_query'].toString().toLowerCase().trim() == normalizedQuery) {
          return doc['response'];
        }
      }
    } catch (e) {
      print("Error checking Firestore: $e");
    }
    return null;
  }

  // Function to call AI API dynamically
  Future<String> _getAIResponse(String query) async {
    final url = Uri.parse("url");
    final headers = {
      "Authorization": "Bearer $_apiKey",
      "Content-Type": "application/json"
    };
    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": "You are a helpful chatbot."},
        {"role": "user", "content": query}
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      }
    } catch (e) {
      print("Error fetching AI response: $e");
    }
    return "Sorry, I don't have an answer for that.";
  }

  // Function to save query and response to Firestore
  Future<void> _saveToFirebase(String query, String response) async {
    try {
      final normalizedQuery = query.toLowerCase().trim();
      final existingDocs = await _firestore
          .collection('chat_responses')
          .where('user_query', isEqualTo: normalizedQuery)
          .get();

      if (existingDocs.docs.isEmpty) {
        await _firestore.collection('chat_responses').add({
          'user_query': normalizedQuery,
          'response': response,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error saving to Firebase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lifeshare Chatbot"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isUser = message.containsKey("user");

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message.values.first,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.blue[900] : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        getResponse(query);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      getResponse(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
