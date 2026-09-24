import 'package:croc_iocl_atos/home/bloc/ro_bloc.dart';
import 'package:croc_iocl_atos/home/bloc/ro_event.dart';
import 'package:croc_iocl_atos/home/bloc/ro_state.dart';
import 'package:croc_iocl_atos/home/ui/ro_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ip_not_configured_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loaded = false;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (!_loaded) {
    _loaded = true;
    context.read<RoBloc>().add(const ProbeApi());

  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return BlocBuilder<RoBloc, RoState>(
  //     builder: (context, state) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: switch (state) {
  //           RoInitial() || RoLoading() => const Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           RoLoaded(:final ro) => ListView(
  //               children: [
  //                 RoDetailsCard(ro: ro),
  //               ],
  //             ),
  //           RoError(:final message) => Center(
  //               child: Text(message),
  //             ),
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<RoBloc, RoState>(
  builder: (context, state) {
   return switch (state) {
  RoInitial() || RoApiProbing() || RoLoading() => const Center(
      child: CircularProgressIndicator(),
    ),
  RoApiNotConfigured() => const ApiNotConfiguredScreen(),
  RoLoaded(:final ro) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Outlet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Overview of your registered retail outlet",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        RoDetailsCard(
           ro: ro,
            config: context.read<RoBloc>().roConfig,
          ),
      ],
    ),
  RoError(:final message) => Center(child: Text(message)),
};
  },
),
        ),
      ),
    );
  }
}
