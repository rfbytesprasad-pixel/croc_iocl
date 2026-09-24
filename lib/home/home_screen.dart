// lib/home/home_screen.dart
import 'dart:async';

import 'package:croc_iocl_atos/actions/ui/action_screen.dart';
import 'package:croc_iocl_atos/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/bloc/ro_bloc.dart';
import '../home/bloc/ro_state.dart';
import '../home/ui/ip_not_configured_screen.dart';
import '../pump/ui/pump_screen.dart';
import '../tank/ui/tank_screen.dart';
import '../home/ui/connecting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Timer _clockTimer;
   bool _hasBooted = false;   

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomePage(),
    const PumpScreen(),
    const TankScreen(),
    const ActionsScreen(),
  ];

  String _headerSubtitle() {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return 'User 1 | $date $time';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoBloc, RoState>(
      builder: (context, state) {
      // Boot is complete the first time we reach a "settled" state —
// meaning the initial probe + details fetch either finished or failed.
if (!_hasBooted && (state is RoLoaded || state is RoError)) {
  _hasBooted = true;
}

// Nav is hidden only during the initial boot, during a probe,
// or when the app is blocked because /roconfig couldn't be reached.
// Once booted, subsequent RoLoading (pull-to-refresh, polling, etc.)
// will NOT hide the nav.
final isBlocked = !_hasBooted
    || state is RoApiProbing
    || state is RoApiNotConfigured;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/indian_oil.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Retail Automation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _headerSubtitle(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/atos_blue_icon.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          body: state is RoInitial || state is RoApiProbing
    ? const ConnectingScreen()
    : state is RoApiNotConfigured
        ? const ApiNotConfiguredScreen()
        : IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: isBlocked
              ? null
              : NavigationBar(
                  backgroundColor: Colors.white,
                  indicatorColor:
                      const Color(0xFFF37022).withValues(alpha: 0.12),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon:
                          Icon(Icons.home, color: Color(0xFFF37022)),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.local_gas_station_outlined),
                      selectedIcon: Icon(Icons.local_gas_station,
                          color: Color(0xFFF37022)),
                      label: 'Pumps',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.water_drop_outlined),
                      selectedIcon: Icon(Icons.water_drop,
                          color: Color(0xFFF37022)),
                      label: 'Tanks',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon:
                          Icon(Icons.settings, color: Color(0xFFF37022)),
                      label: 'Actions',
                    ),
                  ],
                ),
        );
      },
    );
  }
}