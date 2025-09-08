// lib/ai_assistant_screen.dart

import 'package.flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  // CORRECTED: This is the new way to initialize the model
  final model = FirebaseAI.instance.generativeModel(
    model: 'gemini-1.5-flash-latest',
  );

  Future<void> _sendPrompt() async {
    if (_promptController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final prompt = [Content.text(_promptController.text)];
      final result = await model.generateContent(prompt);

      if (!mounted) return;
      setState(() {
        _response = result.text ?? 'No response from AI.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _response = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Furniture Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'e.g., "Suggest a good sofa for a small apartment"',
                border: const OutlineInputBorder(),
                suffixIcon: _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
                    : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendPrompt,
                ),
              ),
              onSubmitted: (_) => _sendPrompt(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _response,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}