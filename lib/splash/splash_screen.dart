// import 'package:flutter/material.dart';
// import 'dart:async';

// import '../home/home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(_controller);

//     _scaleAnimation = Tween<double>(
//       begin: 0.7,
//       end: 1,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutBack,
//       ),
//     );

//     _controller.forward();

//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const HomeScreen(),
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               stops: [
//             0.0,
//             0.4,
//             0.7,
//             1.0
//           ],
//               colors: [
//             Color.fromRGBO(243, 112, 34, 1),
//             Color.fromRGBO(243, 112, 34, 0.7),
//             Color.fromRGBO(243, 112, 34, 0.49),
//             Color.fromRGBO(243, 112, 34, 0),
//           ])),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Center(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     "assets/images/india_oil.png",
//                     width: 140,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "My App",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// splash/splash_screen.dart
import 'dart:async';
import 'package:croc_iocl_atos/home/bloc/ro_bloc.dart';
import 'package:croc_iocl_atos/home/bloc/ro_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Status bar: transparent so gradient bleeds under it
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // 2. Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    context.read<RoBloc>().add(
          const LoadRoDetails(),
        );
    // 3. Navigate to HomeScreen after 3s
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 0.75, 1.0],
            colors: [
              Color(0xFFF37022),
              Color(0xCCF37022),
              Color(0x66F37022),
              Color(0x00F37022),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Logos (animated) ──────────────────────────────────────────
              Expanded(
                flex: 55,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/atos.png',
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 28),
                        Image.asset(
                          'assets/images/indian_oil.png',
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Pump illustration with fade-in mask ───────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.20, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                    ],
                  ).createShader(bounds),
                  child: Image.asset(
                    'assets/images/india_oil_pump.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
