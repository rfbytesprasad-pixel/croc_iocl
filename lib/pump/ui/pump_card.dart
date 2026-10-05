// lib/pump/ui/pump_card.dart
import 'package:flutter/material.dart';
import '../../constants/product_options.dart';
import '../../home/model/ro_config_model.dart';
import '../model/pump_status_model.dart';

class PumpCard extends StatelessWidget {
  final PumpStatusModel data;
  final int? duNo;
  final PumpConfig? pumpConfig;

  const PumpCard({
    super.key,
    required this.data,
    this.duNo,
    this.pumpConfig,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = data.badgeColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.10),
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
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(statusColor),
                      const SizedBox(height: 14),
                      _buildNozzleRow(statusColor),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 8),
                      _DataGrid(data: data),
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

  Widget _buildHeader(Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'DU ${duNo ?? "—"} · P${data.pumpAutoId}',
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
    );
  }

  Widget _buildNozzleRow(Color statusColor) {
    final nozzles = pumpConfig?.nozzleList ?? const <NozzleConfig>[];

    // If no nozzles in config, show a single bubble for the active nozzle.
    if (nozzles.isEmpty) {
      return Center(
        child: _NozzleBubble(
          label: 'N${data.nozzleAutoId}',
          isActive: true,
          statusColor: statusColor,
          assetPath: data.nozzleImagePath,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: nozzles.map((n) {
        final isActive = n.nozzleNo == data.nozzleAutoId;
        return _NozzleBubble(
          label: 'N${n.nozzleNo}',
          productNo: n.productNo,
          isActive: isActive,
          statusColor: statusColor,
          assetPath: isActive ? data.nozzleImagePath : null,
        );
      }).toList(),
    );
  }
}

// ── Nozzle bubble ─────────────────────────────────────────────────────────
class _NozzleBubble extends StatelessWidget {
  final String label;
  final int? productNo;
  final bool isActive;
  final Color statusColor;
  final String? assetPath;

  const _NozzleBubble({
    required this.label,
    this.productNo,
    required this.isActive,
    required this.statusColor,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isActive ? statusColor : Colors.grey.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: activeColor,
                  width: isActive ? 2 : 1,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: _buildImage(),
            ),
            if (isActive && assetPath != null && assetPath!.endsWith('.gif'))
              _PulsingRing(color: statusColor, size: 56),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isActive ? statusColor : Colors.grey.shade500,
          ),
        ),
        if (productNo != null) ...[
          const SizedBox(height: 1),
          Text(
            productNameFromId(productNo!),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isActive ? statusColor.withValues(alpha: 0.9) : Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImage() {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.local_gas_station_rounded,
          size: 26,
          color: statusColor,
        ),
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isActive ? statusColor : Colors.grey.shade400,
        BlendMode.srcIn,
      ),
      child: Image.asset(
        'assets/nozzleIcons/nozzle.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.local_gas_station_rounded,
          size: 26,
          color: isActive ? statusColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}

/// Subtle pulsing ring — appears around a fuelling nozzle.
class _PulsingRing extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingRing({required this.color, required this.size});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final scale = 1.0 + t * 0.35;
        final opacity = (1 - t) * 0.5;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Data grid ─────────────────────────────────────────────────────────────
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