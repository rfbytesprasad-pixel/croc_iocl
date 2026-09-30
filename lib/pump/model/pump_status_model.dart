// lib/pump/model/pump_status_model.dart

import 'package:flutter/material.dart';

enum PumpStatus {
  inoperative,
  idle,
  calling,
  authorized,
  fuelling,
  suspended,
  saleEnd,
  offline,
  error,
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

  const PumpStatusModel({
    required this.roAutoId,
    required this.nozzleAutoId,
    required this.pumpAutoId,
    required this.status,
    required this.trxnVolume,
    required this.trxnAmount,
    required this.unitRate,
    required this.volumeTotalizer,
    required this.interlockStatus,
  });

  static PumpStatus _parseStatus(int code) {
    switch (code) {
      case 1:
        return PumpStatus.inoperative;
      case 2:
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
      case 0:
        return PumpStatus.offline;
      default:
        return PumpStatus.unknown;
    }
  }

  factory PumpStatusModel.fromJson(Map<String, dynamic> json) {
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

  /// Single source of truth for the pump's status color.
  Color get badgeColor {
    switch (status) {
      case PumpStatus.inoperative:
        return const Color(0xFFD32F2F);
      case PumpStatus.idle:
        return const Color(0xFFF9A825);
      case PumpStatus.calling:
        return const Color(0xFFF37022);
      case PumpStatus.authorized:
        return const Color(0xFF1E88E5);
      case PumpStatus.fuelling:
        return const Color(0xFF2E7D32);
      case PumpStatus.suspended:
        return const Color(0xFF7B1FA2);
      case PumpStatus.saleEnd:
        return const Color(0xFF00897B);
      case PumpStatus.offline:
        return const Color(0xFFD32F2F);
      case PumpStatus.error:
        return const Color(0xFFB71C1C);
      case PumpStatus.unknown:
        return const Color(0xFF9E9E9E);
    }
  }

  Color get badgeColorSoft => badgeColor.withValues(alpha: 0.12);

  bool get isFuelling => status == PumpStatus.fuelling;

  // ── Status → nozzle image asset ─────────────────────────────────────────
  /// Returns the asset path for the current status.
  /// - fuelling → animated gif (drops coming out)
  /// - others → static icon
  /// - unknown/error → null (caller falls back to a plain icon)
  String? get nozzleImagePath {
    switch (status) {
      case PumpStatus.fuelling:
        return 'assets/nozzleIcons/fuelling.gif';
      case PumpStatus.idle:
        return 'assets/nozzleIcons/idle.png';
      case PumpStatus.authorized:
        return 'assets/nozzleIcons/authorized.png';
      case PumpStatus.calling:
        return 'assets/nozzleIcons/calling.png';
      case PumpStatus.saleEnd:
        return 'assets/nozzleIcons/saleend.png';
      case PumpStatus.suspended:
        return 'assets/nozzleIcons/suspended.png';
      case PumpStatus.inoperative:
      case PumpStatus.offline:
        return 'assets/nozzleIcons/OFFLINE.jpg';
      case PumpStatus.error:
      case PumpStatus.unknown:
        return null;
    }
  }
}