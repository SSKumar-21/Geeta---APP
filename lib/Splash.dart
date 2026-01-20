import 'package:flutter/material.dart';
import 'package:geeta2/Home.dart';
import 'music.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double op = 0.0;


  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() => op = 1.0);
      await MusicService().play(); // 👈 ensures start
    });

    Future.delayed(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: op,
            duration: const Duration(seconds: 2),
            child: Image.asset(
              'assets/media/slpash.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
