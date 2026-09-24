import 'package:croc_iocl_atos/core/constants.dart';
import 'package:croc_iocl_atos/home/bloc/ro_bloc.dart';
import 'package:croc_iocl_atos/home/data/ro_api_client.dart';
import 'package:croc_iocl_atos/home/data/ro_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
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
