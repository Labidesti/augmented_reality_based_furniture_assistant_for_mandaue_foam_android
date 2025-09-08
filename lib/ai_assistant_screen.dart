// lib/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    final ai = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
    _model = ai.generativeModel(model: 'gemini-2.5-flash');
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final result = await _model.generateContent([Content.text(text)]);
      if (!mounted) return;
      setState(() {
        _response = result.text ?? 'No response from AI.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Furniture Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'e.g., "Suggest a good sofa for a small apartment"',
                border: const OutlineInputBorder(),
                suffixIcon: _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(8),
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
                child: SelectableText(_response, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
