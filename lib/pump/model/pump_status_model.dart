// lib/pump/model/pump_status_model.dart

import 'package:flutter/material.dart';

enum PumpStatus {
  inoperative, // 1
  idle, // 2
  calling, // 3
  authorized, // 4
  fuelling, // 5
  suspended, // 6
  saleEnd, // 7
  offline, // 8
  error, // 9
  unknown,
}

class PumpStatusModel {
  final int roAutoId;
  final int nozzleAutoId;
  final int pumpAutoId;
  final PumpStatus status;
  final double trxnVolume;
  final double trxnAmount;
  final double unitRate;
  final double volumeTotalizer;
  final int interlockStatus;

  const PumpStatusModel(
      {required this.roAutoId,
      required this.nozzleAutoId,
      required this.pumpAutoId,
      required this.status,
      required this.trxnVolume,
      required this.trxnAmount,
      required this.unitRate,
      required this.volumeTotalizer,
      required this.interlockStatus});

  // ── Parse integer code from API → PumpStatus enum ──────────────────────────
  static PumpStatus _parseStatus(int code) {
    switch (code) {
      case 1:
        return PumpStatus.inoperative;
      case 2:
        print("inside idel");
        return PumpStatus.idle;
      case 3:
        return PumpStatus.calling;
      case 4:
        return PumpStatus.authorized;
      case 5:
        return PumpStatus.fuelling;
      case 6:
        return PumpStatus.suspended;
      case 7:
        return PumpStatus.saleEnd;
      case 8:
        return PumpStatus.offline;
      case 9:
        return PumpStatus.error;

      // Optional: keep for backward compatibility if older firmware sends 0.
      case 0:
        return PumpStatus.offline;

      default:
        return PumpStatus.unknown;
    }
  }

  // ── Build model from raw API JSON ──────────────────────────────────────────
  // factory PumpStatusModel.fromJson(Map<String, dynamic> json) {
  //   // The API wraps everything under "pumpstatus" key
  //   final data = json['pumpstatus'] as Map<String, dynamic>;

  //   return PumpStatusModel(
  //     roAutoId: int.tryParse(data['roautoid'].toString()) ?? 0,
  //     nozzleAutoId: int.tryParse(data['nozzleAutoId'].toString()) ?? 0,
  //     pumpAutoId: int.tryParse(data['pumpautoId'].toString()) ?? 0,
  //     status: _parseStatus(
  //       int.tryParse(data['pumpstatus'].toString()) ?? -1,
  //     ),
  //     // Defensive parse — doc says values may arrive as strings or decimals
  //     trxnVolume: double.tryParse(data['trxnVolume'].toString()) ?? 0.0,
  //     trxnAmount: double.tryParse(data['trxnAmount'].toString()) ?? 0.0,
  //   );
  // }

  factory PumpStatusModel.fromJson(Map<String, dynamic> json) {
    // Works for both:
    // { "pumpstatus": { ... } }         ← single
    // { "pumpstatus": { ... } }         ← after we wrap each item above
    final data = json['pumpstatus'] as Map<String, dynamic>;

    return PumpStatusModel(
      roAutoId: int.tryParse(data['roautoid'].toString()) ?? 0,
      nozzleAutoId: int.tryParse(data['nozzleAutoId'].toString()) ?? 0,
      pumpAutoId: int.tryParse(data['pumpautoId'].toString()) ?? 0,
      status: _parseStatus(
        int.tryParse(data['pumpstatus'].toString()) ?? -1,
      ),
      trxnVolume: double.tryParse(data['trxnVolume'].toString()) ?? 0.0,
      trxnAmount: double.tryParse(data['trxnAmount'].toString()) ?? 0.0,
      unitRate: double.tryParse(data['unitRate'].toString()) ?? 0.0,
      volumeTotalizer:
          double.tryParse(data['volumeTotalizer'].toString()) ?? 0.0,
      interlockStatus: int.tryParse(data['interlockStatus'].toString()) ?? 0,
    );
  }
  // ── Status → display label ─────────────────────────────────────────────────
  String get statusLabel {
    switch (status) {
      case PumpStatus.inoperative:
        return 'Inoperative';
      case PumpStatus.idle:
        return 'Idle';
      case PumpStatus.calling:
        return 'Calling';
      case PumpStatus.authorized:
        return 'Authorized';
      case PumpStatus.fuelling:
        return 'Fuelling';
      case PumpStatus.suspended:
        return 'Suspended';
      case PumpStatus.saleEnd:
        return 'Sale End';
      case PumpStatus.offline:
        return 'Offline';
      case PumpStatus.error:
        return 'Error';
      case PumpStatus.unknown:
        return 'Unknown';
    }
  }

  // ── Status → gradient colors (matches your doc's color spec) ──────────────
  List<Color> get gradientColors {
    switch (status) {
      case PumpStatus.inoperative:
        return [const Color.fromARGB(255, 232, 39, 39), Colors.red.shade700];

      case PumpStatus.idle:
        return [Colors.blueGrey.shade300, Colors.blueGrey.shade600];

      case PumpStatus.calling:
        return [const Color(0xFFFFB74D), const Color(0xFFF37022)];

      case PumpStatus.authorized:
        return [Colors.blue.shade300, Colors.blue.shade700];

      case PumpStatus.fuelling:
        return [Colors.green.shade300, Colors.green.shade700];

      case PumpStatus.suspended:
        return [Colors.purple.shade300, Colors.purple.shade700];

      case PumpStatus.saleEnd:
        return [Colors.teal.shade300, Colors.teal.shade700];

      case PumpStatus.offline:
        return [Colors.grey.shade400, Colors.grey.shade700];

      case PumpStatus.error:
        return [Colors.red.shade300, Colors.red.shade900];

      case PumpStatus.unknown:
        return [Colors.grey.shade300, Colors.grey.shade500];
    }
  }

  // ── Status → badge color ───────────────────────────────────────────────────
  Color get badgeColor {
    switch (status) {
      case PumpStatus.inoperative:
        return Colors.red.shade700;

      case PumpStatus.idle:
        return Colors.blueGrey.shade600;

      case PumpStatus.calling:
        return const Color(0xFFF37022);

      case PumpStatus.authorized:
        return Colors.blue.shade700;

      case PumpStatus.fuelling:
        return Colors.green.shade700;

      case PumpStatus.suspended:
        return Colors.purple.shade700;

      case PumpStatus.saleEnd:
        return Colors.teal.shade700;

      case PumpStatus.offline:
        return Colors.red.shade900;

      case PumpStatus.error:
        return Colors.red.shade900;

      case PumpStatus.unknown:
        return Colors.grey.shade500;
    }
  }

  // ── Status → nozzle image asset (null if no image available) ──────────────
  String? get nozzleImagePath {
    switch (status) {
      case PumpStatus.offline:
        return 'assets/nozzleIcons/OFFLINE.jpg';

      case PumpStatus.authorized:
        return 'assets/nozzleIcons/authorized.png';

      case PumpStatus.calling:
        return 'assets/nozzleIcons/calling.png';

      case PumpStatus.saleEnd:
        return 'assets/nozzleIcons/saleend.png';

      case PumpStatus.inoperative:
        return 'assets/nozzleIcons/OFFLINE.jpg';
      case PumpStatus.idle:
        return 'assets/nozzleIcons/idle.png';
      case PumpStatus.fuelling:
        print("isnide fuelling");
        return 'assets/nozzleIcons/fuelling.gif';
      case PumpStatus.suspended:
        return 'assets/nozzleIcons/suspended.png';
      case PumpStatus.error:
      case PumpStatus.unknown:
        return null; // No image available
    }
  }
}
