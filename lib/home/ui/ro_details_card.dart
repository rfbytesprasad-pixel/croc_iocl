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
          // Header band with gradient + logo
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
                // Tappable RO Code — expands to show config details.
                // If config is null, expansion is disabled.
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

                // Expanded config details (only shown when config is loaded)
                if (_expanded && config != null) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.storefront_outlined,
                    title: "RO Name",
                    value: config.roName.isEmpty ? '—' : config.roName,
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.devices_other_outlined,
                    title: "Total DUs",
                    value: config.totalDUs.toString(),
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