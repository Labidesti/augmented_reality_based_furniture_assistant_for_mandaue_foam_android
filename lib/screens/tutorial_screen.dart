import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> tutorialPages = [
    "assets/tutorial/page1.png",
    "assets/tutorial/page2.png",
    "assets/tutorial/page3.png",
    "assets/tutorial/page4.png",
  ];

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenTutorial', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    if (_currentPage < tutorialPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: tutorialPages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  tutorialPages[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              );
            },
          ),

          // Page indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tutorialPages.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),

          // Skip / Done button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _finishTutorial,
              child: Text(
                _currentPage == tutorialPages.length - 1 ? "Done" : "Skip",
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),

          // Back arrow
          if (_currentPage > 0)
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height / 2 - 30,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 32),
                onPressed: _prevPage,
              ),
            ),

          // Next arrow
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: IconButton(
              icon: Icon(
                _currentPage == tutorialPages.length - 1
                    ? Icons.check
                    : Icons.arrow_forward_ios,
                size: 32,
              ),
              onPressed: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}