import 'package:flutter/material.dart';
import 'package:studybuddy/screens/auth/log_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'app_logo',
                child: SizedBox(
                  width: 300,

                  child: Image.asset("assets/logo.png", fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),

              // const SizedBox(height: 10),
              // Text(
              //   'Learn Smarter, Not Harder',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.white.withOpacity(0.8),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
