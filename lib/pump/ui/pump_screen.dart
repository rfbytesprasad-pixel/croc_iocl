// lib/pump/ui/pump_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/bloc/ro_bloc.dart';
import '../../home/model/ro_config_model.dart';
import '../bloc/pump_bloc.dart';
import '../bloc/pump_event.dart';
import '../bloc/pump_state.dart';
import '../data/pump_api_client.dart';
import '../data/pump_repository.dart';
import '../model/pump_status_model.dart';
import '../../core/constants.dart';
import 'pump_card.dart';

class PumpScreen extends StatelessWidget {
  const PumpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PumpBloc(
        repository: PumpRepository(
          apiClient: PumpApiClient(baseUrl: AppConstants.baseUrl),
        ),
      )..add(const PumpStartPolling()),
      child: const _PumpView(),
    );
  }
}

class _PumpView extends StatefulWidget {
  const _PumpView();

  @override
  State<_PumpView> createState() => _PumpViewState();
}

class _PumpViewState extends State<_PumpView> {
  @override
  void dispose() {
    context.read<PumpBloc>().add(const PumpStopPolling());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpBloc, PumpState>(
      builder: (context, state) {
        return switch (state) {
          PumpInitial() => const _LoadingView(),
          PumpLoading() => const _LoadingView(),
          PumpLoaded(:final pumps, :final isRefreshing) => pumps.isEmpty
              ? const _EmptyPumpsView()
              : _LoadedView(pumps: pumps, isRefreshing: isRefreshing),
          PumpError(
            :final message,
            :final hasPreviousData,
            :final previousPumps
          ) =>
            hasPreviousData
                ? _LoadedView(
                    pumps: previousPumps!,
                    isRefreshing: false,
                    errorBanner: message,
                  )
                : const _EmptyPumpsView(),
        };
      },
    );
  }
}

// ── Loading skeleton ───────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 36) / 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          8,
          (_) => SizedBox(width: cardWidth, child: const _SkeletonCard()),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loaded ─────────────────────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final List<PumpStatusModel> pumps;
  final bool isRefreshing;
  final String? errorBanner;

  const _LoadedView({
    required this.pumps,
    required this.isRefreshing,
    this.errorBanner,
  });

  ({int? duNo, PumpConfig? pumpConfig}) _resolvePumpLocation(
    RoConfigModel? config,
    int pumpAutoId,
  ) {
    if (config == null) return (duNo: null, pumpConfig: null);
    for (final du in config.duList) {
      for (final pump in du.pumpList) {
        if (pump.pumpId == pumpAutoId) {
          return (duNo: du.duNo, pumpConfig: pump);
        }
      }
    }
    return (duNo: null, pumpConfig: null);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RoBloc>().roConfig;
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 36) / 2;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pumps.map((p) {
                final loc = _resolvePumpLocation(config, p.pumpAutoId);
                return SizedBox(
                  width: cardWidth,
                  child: PumpCard(
                    data: p,
                    duNo: loc.duNo,
                    pumpConfig: loc.pumpConfig,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state — no live data, but config is known ────────────────────────
class _EmptyPumpsView extends StatelessWidget {
  const _EmptyPumpsView();

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RoBloc>().roConfig;
    final totalPumps = config?.totalPumps ?? 4;

    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 36) / 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
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
                    'Live pump data unavailable. Showing $totalPumps pump slots from configuration.',
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              totalPumps,
              (i) => SizedBox(
                width: cardWidth,
                child: _EmptyPumpCard(pumpNumber: i + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPumpCard extends StatelessWidget {
  final int pumpNumber;
  const _EmptyPumpCard({required this.pumpNumber});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: grey, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: Colors.grey.shade400),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pump $pumpNumber',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
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
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(color: grey),
                          ),
                          child: Icon(
                            Icons.local_gas_station_outlined,
                            size: 26,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 8),
                      const _EmptyDataRow(leftLabel: 'Amount', rightLabel: 'Volume'),
                      const SizedBox(height: 6),
                      const _EmptyDataRow(leftLabel: 'Rate', rightLabel: 'Totalizer'),
                      const SizedBox(height: 6),
                      const _EmptyDataRow(leftLabel: 'RO ID', rightLabel: 'Interlock'),
                    ],
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

class _EmptyDataRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;

  const _EmptyDataRow({required this.leftLabel, required this.rightLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EmptyDataItem(label: leftLabel)),
        Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: Colors.grey.shade200,
        ),
        Expanded(child: _EmptyDataItem(label: rightLabel)),
      ],
    );
  }
}

class _EmptyDataItem extends StatelessWidget {
  final String label;
  const _EmptyDataItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 1),
        Text(
          '—',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}