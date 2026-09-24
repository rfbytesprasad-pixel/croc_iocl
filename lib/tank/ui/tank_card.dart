// lib/tank/ui/tank_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:croc_iocl_atos/constants/tank_status.dart';   // ← ADDED

class AnimatedTankWidget extends StatefulWidget {
  final String tankId;
  final String productName;
  final double productLevel;
  final double waterLevel;
  final double productVolume;
  final double capacity;
  final int status;
  final double waterVolume;

  const AnimatedTankWidget({
    super.key,
    required this.tankId,
    required this.productName,
    required this.productLevel,
    required this.waterLevel,
    required this.productVolume,
    required this.capacity,
    required this.status,
    required this.waterVolume,
  });

  @override
  State<AnimatedTankWidget> createState() => _AnimatedTankWidgetState();
}

class _AnimatedTankWidgetState extends State<AnimatedTankWidget>
    with TickerProviderStateMixin {
  late AnimationController _levelController;
  late AnimationController _waveController;
  late AnimationController _glowController;

  late Animation<double> _productAnimation;
  late Animation<double> _waterAnimation;

  double _previousProduct = 0;
  double _previousWater = 0;

  @override
  void initState() {
    super.initState();

    _levelController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _levelController.forward();
    });
  }

  void _initializeAnimations() {
    final productPercent =
        (widget.productVolume / widget.capacity).clamp(0.0, 1.0);
    final waterPercent = (widget.waterVolume / widget.capacity).clamp(0.0, 1.0);

    _productAnimation = Tween<double>(
      begin: _previousProduct,
      end: productPercent,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));

    _waterAnimation = Tween<double>(
      begin: _previousWater,
      end: waterPercent,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedTankWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.productVolume != widget.productVolume ||
        oldWidget.waterVolume != widget.waterVolume) {
      _previousProduct = _productAnimation.value;
      _previousWater = _waterAnimation.value;

      _initializeAnimations();
      _levelController.forward(from: 0);
      _glowController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ── Status helpers — the ONLY place status is interpreted ────────────────
  Color _statusColor() {
    if (isTankOnline(widget.status)) return const Color(0xFF2E7D32); // green
    if (isTankOffline(widget.status)) return Colors.red.shade700;    // red
    return Colors.grey.shade500;                                     // unknown
  }

  String _statusLabel() {
    if (isTankOnline(widget.status)) return 'Online';
    if (isTankOffline(widget.status)) return 'Offline';
    return 'Unknown';
  }

  Color _getProductColor() {
    switch (widget.productName.toUpperCase()) {
      case 'MS':
        return const Color(0xFFF57C00);
      case 'HSD':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFFC62828);
    }
  }

  LinearGradient _getProductGradient() {
    switch (widget.productName.toUpperCase()) {
      case 'MS':
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'HSD':
        return const LinearGradient(
          colors: [Color(0xFF5470C6), Color(0xFF2A4BAD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFA0404), Color(0xFFB00000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  // ── Fill + ullage helpers ────────────────────────────────────────────────
  double get _fillPercent =>
      ((widget.productVolume + widget.waterVolume) / widget.capacity)
          .clamp(0.0, 1.0) *
      100;

  double get _ullage => widget.capacity - widget.productVolume;

  @override
  Widget build(BuildContext context) {
    final productColor = _getProductColor();

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status stripe ────────────────────────────────────────
              Container(
                width: 6,
                color: _statusColor(),
              ),

              // ── Card body ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(productColor),
                      const SizedBox(height: 14),
                      _buildTankVisualization(),
                      const SizedBox(height: 14),
                      _buildStatsPanel(productColor),
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

  Widget _buildHeader(Color productColor) {
    return Row(
      children: [
        Text(
          'Tank ${widget.tankId}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(width: 10),

        // ── Product badge ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: productColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: productColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            widget.productName.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: productColor,
            ),
          ),
        ),

        const Spacer(),

        // ── Status — dot + label ─────────────────────────────────────
        Row(
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(),
                    boxShadow: isTankOnline(widget.status)
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(
                                  alpha: 0.5 * _glowController.value),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 5),
            Text(
              _statusLabel(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _statusColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tank visualization ───────────────────────────────────────────────────
  Widget _buildTankVisualization() {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: Listenable.merge([_levelController, _waveController]),
        builder: (context, child) {
          return CustomPaint(
            painter: CylindricalTankPainter(
              productPercent: _productAnimation.value,
              waterPercent: _waterAnimation.value,
              productGradient: _getProductGradient(),
              waveAnimation: _waveController.value,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_fillPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Total Fill',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stats panel ──────────────────────────────────────────────────────────
  Widget _buildStatsPanel(Color productColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStatRow(
            label: 'Product Level',
            value: '${widget.productLevel.toStringAsFixed(0)} mm',
            valueColor: productColor,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'Water Level',
            value: '${widget.waterLevel.toStringAsFixed(0)} mm',
            valueColor: const Color(0xFF1565C0),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFDDDDDD)),
          ),
          _buildStatRow(
            label: 'Volume',
            value: '${widget.productVolume.toStringAsFixed(0)} L',
            valueColor: const Color(0xFF1A1A1A),
            bold: true,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'Ullage',
            value: '${_ullage.toStringAsFixed(0)} L',
            valueColor: const Color(0xFF1A1A1A),
            bold: true,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'Capacity',
            value: '${widget.capacity.toStringAsFixed(0)} L',
            valueColor: const Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color valueColor,
    bool bold = false,
  }) {
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
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── CylindricalTankPainter — unchanged ──────────────────────────────────────
class CylindricalTankPainter extends CustomPainter {
  final double productPercent;
  final double waterPercent;
  final LinearGradient productGradient;
  final double waveAnimation;

  CylindricalTankPainter({
    required this.productPercent,
    required this.waterPercent,
    required this.productGradient,
    required this.waveAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final cylinderWidth = size.width * 0.85;
    final cylinderHeight = size.height * 0.8;
    final capRadius = cylinderHeight / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final leftX = centerX - cylinderWidth / 2;
    final rightX = centerX + cylinderWidth / 2;

    final totalPercent = (productPercent + waterPercent).clamp(0.0, 1.0);
    final waterFillHeight = cylinderHeight * waterPercent;
    final productFillHeight = cylinderHeight * productPercent;
    final totalFillHeight = cylinderHeight * totalPercent;

    _drawCylinder(canvas, paint, leftX, centerY - cylinderHeight / 2,
        cylinderWidth, cylinderHeight, capRadius, Colors.grey[200]!);

    final cylinderClipPath = _getCylinderPath(leftX,
        centerY - cylinderHeight / 2, cylinderWidth, cylinderHeight, capRadius);
    canvas.save();
    canvas.clipPath(cylinderClipPath);

    if (waterPercent > 0) {
      const waterGradient = LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

      final waterRect = Rect.fromLTWH(
          leftX,
          centerY + cylinderHeight / 2 - waterFillHeight,
          cylinderWidth,
          waterFillHeight);

      paint.shader = waterGradient.createShader(waterRect);
      canvas.drawRect(waterRect, paint);
    }

    if (productPercent > 0) {
      final productRect = Rect.fromLTWH(
          leftX,
          centerY + cylinderHeight / 2 - totalFillHeight,
          cylinderWidth,
          productFillHeight);

      paint.shader = productGradient.createShader(productRect);
      canvas.drawRect(productRect, paint);

      _drawWaveSurface(
          canvas,
          paint,
          leftX,
          centerY + cylinderHeight / 2 - totalFillHeight,
          cylinderWidth,
          capRadius,
          productGradient.colors[0]);
    }

    if (waterPercent > 0 && productPercent > 0) {
      paint.shader = null;
      paint.color = Colors.black;
      paint.strokeWidth = 0.4;
      paint.style = PaintingStyle.stroke;

      final separatorY = centerY + cylinderHeight / 2 - waterFillHeight;
      final separatorPath = Path();
      separatorPath.moveTo(leftX + capRadius, separatorY);
      separatorPath.lineTo(rightX - capRadius, separatorY);
      canvas.drawPath(separatorPath, paint);
    }

    if (totalPercent > 0) {
      paint.style = PaintingStyle.fill;
      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(
          leftX,
          centerY + cylinderHeight / 2 - totalFillHeight,
          cylinderWidth,
          totalFillHeight));

      canvas.drawRect(
          Rect.fromLTWH(leftX, centerY + cylinderHeight / 2 - totalFillHeight,
              cylinderWidth, totalFillHeight),
          paint);
    }

    canvas.restore();

    paint.shader = null;
    paint.color = Colors.grey[600]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    _drawCylinderOutline(canvas, paint, leftX, centerY - cylinderHeight / 2,
        cylinderWidth, cylinderHeight, capRadius);
  }

  void _drawCylinder(Canvas canvas, Paint paint, double x, double y,
      double width, double height, double capRadius, Color color) {
    paint.color = color;
    paint.style = PaintingStyle.fill;
    final path = _getCylinderPath(x, y, width, height, capRadius);
    canvas.drawPath(path, paint);
  }

  Path _getCylinderPath(
      double x, double y, double width, double height, double capRadius) {
    final path = Path();
    path.addArc(
      Rect.fromLTWH(x, y, capRadius * 2, height),
      math.pi / 2,
      math.pi,
    );
    path.lineTo(x + width - capRadius, y);
    path.addArc(
      Rect.fromLTWH(x + width - capRadius * 2, y, capRadius * 2, height),
      -math.pi / 2,
      math.pi,
    );
    path.lineTo(x + capRadius, y + height);
    path.close();
    return path;
  }

  void _drawCylinderOutline(Canvas canvas, Paint paint, double x, double y,
      double width, double height, double capRadius) {
    final path = Path();
    path.addArc(
      Rect.fromLTWH(x, y, capRadius * 2, height),
      math.pi / 2,
      math.pi,
    );
    path.moveTo(x + capRadius, y);
    path.lineTo(x + width - capRadius, y);
    path.addArc(
      Rect.fromLTWH(x + width - capRadius * 2, y, capRadius * 2, height),
      -math.pi / 2,
      math.pi,
    );
    path.moveTo(x + width - capRadius, y + height);
    path.lineTo(x + capRadius, y + height);
    canvas.drawPath(path, paint);
  }

  void _drawWaveSurface(Canvas canvas, Paint paint, double x, double y,
      double width, double capRadius, Color waveColor) {
    final wavePath = Path();
    const waveHeight = 8.0;
    const waveFrequency = 3;

    wavePath.moveTo(x, y - waveHeight);

    for (double i = 0; i <= width; i += 1.5) {
      final waveX = x + i;
      final waveY = (y - waveHeight) +
          math.sin((i / width * math.pi * waveFrequency) +
                  (waveAnimation * 2 * math.pi)) *
              waveHeight;
      wavePath.lineTo(waveX, waveY);
    }

    wavePath.lineTo(x + width, y + waveHeight);
    wavePath.lineTo(x, y + waveHeight);
    wavePath.close();

    paint.shader = null;
    paint.style = PaintingStyle.fill;
    paint.color = waveColor.withValues(alpha: 0.65);
    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(CylindricalTankPainter oldDelegate) {
    return oldDelegate.productPercent != productPercent ||
        oldDelegate.waterPercent != waterPercent ||
        oldDelegate.waveAnimation != waveAnimation;
  }
}