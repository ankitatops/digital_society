import 'package:flutter/material.dart';
import 'dart:ui';
import '../signup/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> data = [
    {
      "image": "assets/onboarding3.png",
      "title": "Smart Society",
      "desc": "Experience modern & digital living",
    },
    {
      "image": "assets/onboarding1.jpg",
      "title": "Stay Connected",
      "desc": "Instant communication with residents",
    },
    {
      "image": "assets/onboarding2.jpg",
      "title": "Secure Life",
      "desc": "Advanced safety & monitoring system",
    },
  ];

  void next() {
    if (currentIndex < data.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => userLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: data.length,
        onPageChanged: (i) => setState(() => currentIndex = i),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(data[index]["image"]!),
                    fit: BoxFit.contain,
                    scale: currentIndex == index ? 1 : 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 20,
                child: Row(
                  children: [
                    Text(
                      "Smart Society",
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 56,
                right: 20,
                child: TextButton(
                  onPressed: () {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => userLoginScreen()),
                      );
                    });
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(color: Colors.teal.shade50, fontSize: 25),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),

                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data[index]["title"]!,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 10),
                            Text(
                              data[index]["desc"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                            ),

                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                data.length,
                                (i) => AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  height: 8,
                                  width: currentIndex == i ? 30 : 8,
                                  decoration: BoxDecoration(
                                    color: currentIndex == i
                                        ? Colors.blue
                                        : Colors.white38,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: next,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade200,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    currentIndex == data.length - 1
                                        ? "Enter App"
                                        : "Next",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
