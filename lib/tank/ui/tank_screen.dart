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
import '../../home/bloc/ro_bloc.dart';

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
          TankLoaded(:final tanks, :final isRefreshing) => tanks.isEmpty
              ? const _EmptyTanksView()
              : _LoadedView(tanks: tanks, isRefreshing: isRefreshing),
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
                : const _EmptyTanksView(),
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
  density: tank.density,
);
            },
          ),
        ),
      ],
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────
class _EmptyTanksView extends StatelessWidget {
  const _EmptyTanksView();

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RoBloc>().roConfig;
    final totalTanks = config?.totalTanks ?? 2;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live tank data unavailable. Showing $totalTanks tank slots from configuration.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          totalTanks,
          (i) => _EmptyTankCard(tankNumber: i + 1),
        ),
      ],
    );
  }
}

class _EmptyTankCard extends StatelessWidget {
  final int tankNumber;
  const _EmptyTankCard({required this.tankNumber});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey.shade300;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: grey, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tank $tankNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'No Data',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: grey),
              ),
              child: Center(
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _EmptyStatRow(label: 'Product Level', value: '— mm'),
            const SizedBox(height: 8),
            const _EmptyStatRow(label: 'Water Level', value: '— mm'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            const _EmptyStatRow(label: 'Volume', value: '— L'),
            const SizedBox(height: 8),
            const _EmptyStatRow(label: 'Ullage', value: '— L'),
            const SizedBox(height: 8),
            const _EmptyStatRow(label: 'Capacity', value: '— L'),
          ],
        ),
      ),
    );
  }
}

class _EmptyStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _EmptyStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
