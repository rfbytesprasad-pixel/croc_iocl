// lib/pump/ui/pump_card.dart
import 'package:flutter/material.dart';
import '../model/pump_status_model.dart';

class PumpCard extends StatelessWidget {
  final PumpStatusModel data;
  /// Which DU this pump belongs to. Null if unknown (no match in /roconfig).
  final int? duNo;

  const PumpCard({
    super.key,
    required this.data,
    this.duNo,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = data.gradientColors.first;

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left stripe
                Container(width: 5, color: statusColor),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  duNo != null
                                      ? 'DU $duNo · P${data.pumpAutoId} · N${data.nozzleAutoId}'
                                      : 'P${data.pumpAutoId} · N${data.nozzleAutoId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data.statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Icon ───────────────────────────────────
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor.withValues(alpha: 0.10),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.20),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: data.nozzleImagePath != null
                                  ? Image.asset(
                                      data.nozzleImagePath!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          _fallbackIcon(statusColor),
                                    )
                                  : _fallbackIcon(statusColor),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Divider ────────────────────────────────
                        Divider(height: 1, color: Colors.grey.shade100),

                        const SizedBox(height: 8),

                        // ── Data Grid ──────────────────────────────
                        _DataGrid(data: data),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(Color color) {
    return Icon(
      Icons.local_gas_station_rounded,
      color: color,
      size: 24,
    );
  }
}

// ── 2-column data grid ─────────────────────────────────────────────────────
class _DataGrid extends StatelessWidget {
  final PumpStatusModel data;
  const _DataGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DataRow(
          leftLabel: 'Amount',
          leftValue: '₹${data.trxnAmount.toStringAsFixed(2)}',
          rightLabel: 'Volume',
          rightValue: '${data.trxnVolume.toStringAsFixed(2)} L',
        ),
        const SizedBox(height: 6),
        _DataRow(
          leftLabel: 'Rate',
          leftValue: '₹${data.unitRate.toStringAsFixed(2)}',
          rightLabel: 'Totalizer',
          rightValue: data.volumeTotalizer.toStringAsFixed(2),
        ),
        const SizedBox(height: 6),
        _DataRow(
          leftLabel: 'RO ID',
          leftValue: '${data.roAutoId}',
          rightLabel: 'Interlock',
          rightValue: '${data.interlockStatus}',
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _DataRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _DataItem(label: leftLabel, value: leftValue)),
        Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: Colors.grey.shade200,
        ),
        Expanded(child: _DataItem(label: rightLabel, value: rightValue)),
      ],
    );
  }
}

class _DataItem extends StatelessWidget {
  final String label;
  final String value;

  const _DataItem({required this.label, required this.value});

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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}