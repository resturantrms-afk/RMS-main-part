import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────
class CategoryData {
  final String name;
  final IconData icon;
  final int totalItems;
  final int revSharePercent;
  final double trendPercent;
  final Color color;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.totalItems,
    required this.revSharePercent,
    required this.trendPercent,
    required this.color,
  });
}

const _foodColor = Color(0xFFE88328);
const _drinksColor = Color(0xFFBBA598);

const _categories = [
  CategoryData(
    name: 'Food',
    icon: Icons.restaurant,
    totalItems: 668,
    revSharePercent: 75,
    trendPercent: 8.5,
    color: _foodColor,
  ),
  CategoryData(
    name: 'Drinks',
    icon: Icons.local_bar,
    totalItems: 215,
    revSharePercent: 25,
    trendPercent: 15.0,
    color: _drinksColor,
  ),
];

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class RevenueSplitTab extends StatelessWidget {
  const RevenueSplitTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Mix Insight card
          const _CategoryMixInsightCard(),
          const SizedBox(height: 24),

          // Chart + Table side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left — donut chart
                Expanded(
                  flex: 5,
                  child: _RevenueDonutCard(categories: _categories),
                ),
                const SizedBox(width: 20),

                // Right — performance table
                Expanded(
                  flex: 7,
                  child: _CategoryPerformanceCard(categories: _categories),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Category Mix Insight Card
// ─────────────────────────────────────────────────────────────
class _CategoryMixInsightCard extends StatelessWidget {
  const _CategoryMixInsightCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative gradient
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon + text
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 26,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category Mix Insight',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.65,
                                color: cs.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Revenue Sources: Food items account for ',
                                ),
                                TextSpan(
                                  text: '75%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' of your total income today. Drinks are making up the remaining ',
                                ),
                                TextSpan(
                                  text: '25%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      '. There is a trend where customers ordering \'Food\' often skip \'Drinks\'; adding a combined \'Meal Deal\' could boost your drink sales significantly.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Revenue by Category — Donut Chart Card
// ─────────────────────────────────────────────────────────────
class _RevenueDonutCard extends StatelessWidget {
  final List<CategoryData> categories;
  const _RevenueDonutCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 32),

          // Donut chart
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated donut
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.75),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOut,
                    builder: (_, value, __) => CustomPaint(
                      size: const Size(220, 220),
                      painter: _DonutPainter(
                        trackColor: _drinksColor.withValues(alpha: 0.5),
                        fillColor: _foodColor,
                        fillFraction: value,
                        strokeWidth: 22,
                      ),
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$12,450',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TOTAL REV',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categories.map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: c.color,
                        shape: BoxShape.circle,
                        boxShadow: c.color == _foodColor
                            ? [
                                BoxShadow(
                                  color: c.color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${c.name} (${c.revSharePercent}%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Donut CustomPainter
// ─────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final Color trackColor;
  final Color fillColor;
  final double fillFraction;
  final double strokeWidth;

  const _DonutPainter({
    required this.trackColor,
    required this.fillColor,
    required this.fillFraction,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track — full circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Fill arc — clockwise from top
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * fillFraction;
    canvas.drawArc(
      rect,
      -math.pi / 2, // start from 12 o'clock
      sweepAngle,
      false,
      fillPaint,
    );

    // Glow pass
    final glowPaint = Paint()
      ..color = fillColor.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.fillFraction != fillFraction;
}

// ─────────────────────────────────────────────────────────────
// Category Performance Table Card
// ─────────────────────────────────────────────────────────────
class _CategoryPerformanceCard extends StatelessWidget {
  final List<CategoryData> categories;
  const _CategoryPerformanceCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Toolbar ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainer.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Category Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ── Column headers ────────────────────────────────
            Container(
              color: cs.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              child: Row(
                children: [
                  _hdr(context, 'CATEGORY NAME', flex: 30),
                  _hdr(
                    context,
                    'TOTAL ITEMS',
                    flex: 22,
                    align: TextAlign.right,
                  ),
                  _hdr(
                    context,
                    'REV SHARE',
                    flex: 20,
                    align: TextAlign.right,
                  ),
                  _hdr(context, 'TREND', flex: 20, align: TextAlign.right),
                ],
              ),
            ),

            // ── Rows ──────────────────────────────────────────
            ...categories.asMap().entries.map((entry) {
              return _CategoryRow(
                category: entry.value,
                isLast: entry.key == categories.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _hdr(
    BuildContext context,
    String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single category row
// ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatefulWidget {
  final CategoryData category;
  final bool isLast;

  const _CategoryRow({required this.category, required this.isLast});

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.category;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered
              ? cs.surfaceContainerHigh.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Row(
                children: [
                  // Category name + icon
                  Expanded(
                    flex: 30,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            c.icon,
                            size: 16,
                            color: c.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total items
                  Expanded(
                    flex: 22,
                    child: Text(
                      c.totalItems.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Rev share badge
                  Expanded(
                    flex: 20,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${c.revSharePercent}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Trend
                  Expanded(
                    flex: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${c.trendPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isLast)
              Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.25),
              ),
          ],
        ),
      ),
    );
  }
}
