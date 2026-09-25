import 'dart:async';

import 'package:croc_iocl_atos/core/constants.dart';
import 'package:croc_iocl_atos/home/bloc/ro_bloc.dart';
import 'package:croc_iocl_atos/home/data/ro_api_client.dart';
import 'package:croc_iocl_atos/home/data/ro_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash/splash_screen.dart';

void main() {
  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    debugPrint('╔═══ FLUTTER ERROR ═══');
    debugPrint('Exception: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    debugPrint('╚════════════════════');
  };

  // Catch async errors not caught by Flutter
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('╔═══ ZONE ERROR ═══');
    debugPrint('Error: $error');
    debugPrint('Stack: $stack');
    debugPrint('╚══════════════════');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoBloc>(
          create: (_) => RoBloc(
            repository: RoRepository(
              apiClient: RoApiClient(
                baseUrl: AppConstants.baseUrl,
              ),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}