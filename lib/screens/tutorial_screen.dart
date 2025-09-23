import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> tutorialImages = [
    'assets/tutorial/page1.png',
    'assets/tutorial/page2.png',
    'assets/tutorial/page3.png',
    'assets/tutorial/page4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for swiping tutorial pages
            PageView.builder(
              controller: _pageController,
              itemCount: tutorialImages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Image.asset(
                    tutorialImages[index],
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                );
              },
            ),

            // Page indicator (dots)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  tutorialImages.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Skip button
            Positioned(
              top: 10,
              right: 15,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/customer');
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ),

            // Next / Done button
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == tutorialImages.length - 1) {
                    Navigator.pushReplacementNamed(context, '/customer');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == tutorialImages.length - 1 ? "Done" : "Next",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
