// lib/tank/ui/tank_screen.dart
import 'package:croc_iocl_atos/tank/ui/tank_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tank_bloc.dart';
import '../bloc/tank_event.dart';
import '../bloc/tank_state.dart';
import '../data/tank_api_client.dart';
import '../data/tank_repository.dart';
import '../model/tank_status_model.dart';

import 'package:croc_iocl_atos/constants/product_options.dart';

class TankScreen extends StatelessWidget {
  const TankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TankBloc(
  tankRepository: TankRepository(
    apiClient: TankApiClient(),
  ),
      )..add(const TankStartPolling()),
      child: const _TankView(),
    );
  }
}

class _TankView extends StatefulWidget {
  const _TankView();

  @override
  State<_TankView> createState() => _TankViewState();
}

class _TankViewState extends State<_TankView> {
  @override
  void dispose() {
    context.read<TankBloc>().add(const TankStopPolling());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TankBloc, TankState>(
      builder: (context, state) {
        return switch (state) {
          TankInitial() => const _LoadingView(),
          TankLoading() => const _LoadingView(),
          TankLoaded(:final tanks, :final isRefreshing) => _LoadedView(
              tanks: tanks,
              isRefreshing: isRefreshing,
            ),
          TankError(
            :final message,
            :final hasPreviousData,
            :final previoustanks
          ) =>
            hasPreviousData
                ? _LoadedView(
                    tanks: previoustanks!,
                    isRefreshing: false,
                    errorBanner: message,
                  )
                : _ErrorView(message: message),
        };
      },
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: 3,
      itemBuilder: (_, __) => const _SkeletonTankCard(),
    );
  }
}

class _SkeletonTankCard extends StatelessWidget {
  const _SkeletonTankCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
                3,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 80,
                              height: 12,
                              color: Colors.grey.shade200),
                          Container(
                              width: 60,
                              height: 12,
                              color: Colors.grey.shade200),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}

// ── Loaded ───────────────────────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final List<TankStatusModel> tanks;
  final bool isRefreshing;
  final String? errorBanner;

  const _LoadedView({
    required this.tanks,
    required this.isRefreshing,
    this.errorBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorBanner != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 16, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorBanner!,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        if (isRefreshing)
          LinearProgressIndicator(
            minHeight: 2,
            color: const Color(0xFFF37022),
            backgroundColor: Colors.orange.shade50,
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: tanks.length,
            itemBuilder: (_, index) {
              final tank = tanks[index];

              return AnimatedTankWidget(
                tankId: tank.tankAutoId.toString(),
                productName: productNameFromId(tank.productId),
                productLevel: tank.productLevel,
                waterLevel: tank.waterLevel,
                productVolume: tank.productVolume,
                capacity: tank.productVolume + tank.ullage,
                status: tank.status,
                waterVolume: tank.waterVolume,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37022),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              onPressed: () {
                context.read<TankBloc>().add(const TankStartPolling());
              },
            ),
          ],
        ),
      ),
    );
  }
}