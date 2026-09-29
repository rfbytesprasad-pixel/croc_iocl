import 'package:flutter/material.dart';

import '../../home/model/ro_config_model.dart';
import '../model/ro_model.dart';

class RoDetailsCard extends StatefulWidget {
  final RoModel ro;
  final RoConfigModel? config;

  const RoDetailsCard({
    super.key,
    required this.ro,
    this.config,
  });

  @override
  State<RoDetailsCard> createState() => _RoDetailsCardState();
}

class _RoDetailsCardState extends State<RoDetailsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ro = widget.ro;
    final config = widget.config;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF37022), Color(0xFFFF9A56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/indian_oil.png',
                    height: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Retail Outlet",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "Active",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tappable RO Code — expands to show config details
                InkWell(
                  onTap: config == null
                      ? null
                      : () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoRow(
                            icon: Icons.confirmation_number_outlined,
                            title: "RO Code",
                            value: ro.roCode.toString(),
                          ),
                        ),
                        if (config != null)
                          Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: const Color(0xFFF37022),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),

                // Expanded config details
                if (_expanded && config != null) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.storefront_outlined,
                    title: "RO Name",
                    value: config.roName.isEmpty ? '—' : config.roName,
                  ),
                  const SizedBox(height: 14),

                  // Total DUs — expandable, shows DU tree when tapped
                  _ExpandableInfoRow(
                    icon: Icons.devices_other_outlined,
                    title: "Total DUs",
                    value: config.totalDUs.toString(),
                    children: config.duList
                        .map((du) => _DuTile(du: du))
                        .toList(),
                  ),

                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.local_gas_station_outlined,
                    title: "Total Pumps",
                    value: config.totalPumps.toString(),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.water_drop_outlined,
                    title: "Total Tanks",
                    value: config.totalTanks.toString(),
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1),
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  title: "Address",
                  value: ro.address,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable info row — same style as _InfoRow but tappable, shows children
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandableInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Widget> children;

  const _ExpandableInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 42, bottom: 4),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF37022).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF37022),
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DU tree: DU → Pumps → Nozzles
// ─────────────────────────────────────────────────────────────────────────────

class _DuTile extends StatelessWidget {
  final DuConfig du;

  const _DuTile({required this.du});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.only(left: 12, bottom: 6),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF37022).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.devices_other_outlined,
            size: 18,
            color: Color(0xFFF37022),
          ),
        ),
        title: Text(
          'DU ${du.duNo}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          '${du.pumpList.length} pumps · ${du.nozzleCount} nozzles',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        children: du.pumpList.map((pump) => _PumpTile(pump: pump)).toList(),
      ),
    );
  }
}

class _PumpTile extends StatelessWidget {
  final PumpConfig pump;

  const _PumpTile({required this.pump});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.only(left: 12, bottom: 4),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(
          Icons.local_gas_station_outlined,
          size: 18,
          color: Color(0xFF666666),
        ),
        title: Text(
          'Pump ${pump.pumpNo}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          '${pump.nozzleList.length} nozzles',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        children:
            pump.nozzleList.map((n) => _NozzleRow(nozzle: n)).toList(),
      ),
    );
  }
}

class _NozzleRow extends StatelessWidget {
  final NozzleConfig nozzle;

  const _NozzleRow({required this.nozzle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            Icons.circle,
            size: 6,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nozzle ${nozzle.nozzleNo}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            'Product ${nozzle.productNo} · Tank ${nozzle.tankNo}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable info row (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF37022).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF37022),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}