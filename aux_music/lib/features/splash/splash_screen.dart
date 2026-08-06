import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String status;

  const SplashScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark minimal background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/icons/Aux_applogo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 50),
            
            // Loading Bar
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
