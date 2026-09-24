// // lib/pump/ui/pump_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/pump_bloc.dart';
// import '../bloc/pump_event.dart';
// import '../bloc/pump_state.dart';
// import '../data/pump_api_client.dart';
// import '../data/pump_repository.dart';
// import '../model/pump_status_model.dart';
// import '../../core/constants.dart';
// import 'pump_card.dart';

// class PumpScreen extends StatelessWidget {
//   const PumpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => PumpBloc(
//         repository: PumpRepository(
//           apiClient: PumpApiClient(baseUrl: AppConstants.baseUrl),
//         ),
//       )..add(const PumpStartPolling()),
//       child: const _PumpView(),
//     );
//   }
// }

// class _PumpView extends StatefulWidget {
//   const _PumpView();

//   @override
//   State<_PumpView> createState() => _PumpViewState();
// }

// class _PumpViewState extends State<_PumpView> {
//   @override
//   void dispose() {
//     context.read<PumpBloc>().add(const PumpStopPolling());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     // On very small screens (<360), cards need to be taller relative to width
//     final aspectRatio =
//         screenWidth < 360 ? 0.78 : (screenWidth < 400 ? 0.85 : 0.95);

//     return BlocBuilder<PumpBloc, PumpState>(
//       builder: (context, state) {
//         return switch (state) {
//           PumpInitial() => _LoadingView(aspectRatio: aspectRatio),
//           PumpLoading() => _LoadingView(aspectRatio: aspectRatio),
//           PumpLoaded(:final pumps, :final isRefreshing) => _LoadedView(
//               pumps: pumps,
//               isRefreshing: isRefreshing,
//               aspectRatio: aspectRatio,
//             ),
//           PumpError(
//             :final message,
//             :final hasPreviousData,
//             :final previousPumps
//           ) =>
//             hasPreviousData
//                 ? _LoadedView(
//                     pumps: previousPumps!,
//                     isRefreshing: false,
//                     aspectRatio: aspectRatio,
//                     errorBanner: message,
//                   )
//                 : _ErrorView(message: message),
//         };
//       },
//     );
//   }
// }

// class _LoadingView extends StatelessWidget {
//   final double aspectRatio;
//   const _LoadingView({required this.aspectRatio});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: aspectRatio,
//       ),
//       itemCount: 8,
//       itemBuilder: (_, __) => const _SkeletonCard(),
//     );
//   }
// }

// class _SkeletonCard extends StatelessWidget {
//   const _SkeletonCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey.shade300,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 80,
//             height: 10,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: 120,
//             height: 10,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LoadedView extends StatelessWidget {
//   final List<PumpStatusModel> pumps;
//   final bool isRefreshing;
//   final double aspectRatio;
//   final String? errorBanner;

//   const _LoadedView({
//     required this.pumps,
//     required this.isRefreshing,
//     required this.aspectRatio,
//     this.errorBanner,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (errorBanner != null)
//           Container(
//             width: double.infinity,
//             color: Colors.red.shade50,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.wifi_off_rounded,
//                     size: 16, color: Colors.red.shade700),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     errorBanner!,
//                     style: TextStyle(fontSize: 12, color: Colors.red.shade700),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         if (isRefreshing)
//           LinearProgressIndicator(
//             minHeight: 2,
//             color: const Color(0xFFF37022),
//             backgroundColor: Colors.orange.shade50,
//           ),
//         Expanded(
//           child: GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: aspectRatio,
//             ),
//             itemCount: pumps.length,
//             itemBuilder: (context, index) => PumpCard(data: pumps[index]),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ErrorView extends StatelessWidget {
//   final String message;
//   const _ErrorView({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.cloud_off_rounded,
//                 size: 64, color: Colors.grey.shade300),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF37022),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//               onPressed: () {
//                 context.read<PumpBloc>().add(const PumpStartPolling());
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/pump/ui/pump_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          PumpLoaded(:final pumps, :final isRefreshing) => _LoadedView(
              pumps: pumps,
              isRefreshing: isRefreshing,
            ),
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
                : _ErrorView(message: message),
        };
      },
    );
  }
}

// ── Wrap-based layout: cards take natural height, zero overflow ─────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 36) / 2; // padding 12*2 + spacing 12

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          8,
          (_) => SizedBox(
            width: cardWidth,
            child: const _SkeletonCard(),
          ),
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

class _LoadedView extends StatelessWidget {
  final List<PumpStatusModel> pumps;
  final bool isRefreshing;
  final String? errorBanner;

  const _LoadedView({
    required this.pumps,
    required this.isRefreshing,
    this.errorBanner,
  });

  @override
  Widget build(BuildContext context) {
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
              children: pumps
                  .map((p) => SizedBox(
                        width: cardWidth,
                        child: PumpCard(data: p),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

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
            Icon(Icons.cloud_off_rounded,
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
                context.read<PumpBloc>().add(const PumpStartPolling());
              },
            ),
          ],
        ),
      ),
    );
  }
}
