import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_event.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_state.dart';
import 'package:rmss/features/admin/models/reports/category_performance_report.dart';
import 'package:rmss/core/services/ai_services.dart';

// ─────────────────────────────────────────────────────────────
// Time filter
// ─────────────────────────────────────────────────────────────
enum _TimeRange { today, thisWeek, thisMonth, allTime }

extension _TimeRangeLabel on _TimeRange {
  String get label {
    switch (this) {
      case _TimeRange.today:
        return 'Today';
      case _TimeRange.thisWeek:
        return 'This Week';
      case _TimeRange.thisMonth:
        return 'This Month';
      case _TimeRange.allTime:
        return 'All Time';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Computed model
// ─────────────────────────────────────────────────────────────
class _CategorySplit {
  final String name;
  final double revenue;
  final int itemsSold;

  const _CategorySplit({
    required this.name,
    required this.revenue,
    required this.itemsSold,
  });
}

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class RevenueSplitTab extends StatefulWidget {
  final GlobalKey? exportKey;
  
  const RevenueSplitTab({super.key, this.exportKey});

  @override
  State<RevenueSplitTab> createState() => _RevenueSplitTabState();
}

class _RevenueSplitTabState extends State<RevenueSplitTab> {
  _TimeRange _selected = _TimeRange.today;
  String? _aiAdvice;
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFor(_selected);
    });
  }

  void _loadDataFor(_TimeRange range) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (range) {
      case _TimeRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _TimeRange.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _TimeRange.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _TimeRange.allTime:
        startDate = null;
        endDate = null;
        break;
    }

    context.read<ReportsBloc>().add(
      LoadReports(startDate: startDate, endDate: endDate),
    );
  }

  void _onTimeRangeSelected(_TimeRange r) {
    setState(() {
      _selected = r;
      _aiAdvice = null;
    });
    _loadDataFor(r);
  }

  Future<void> _fetchAiAdvice(List<_CategorySplit> categories) async {
    if (categories.isEmpty || _aiAdvice != null || _isLoadingAi) return;

    setState(() => _isLoadingAi = true);
    final summary = categories
        .take(3)
        .map((e) => "${e.name} (\$${e.revenue.toStringAsFixed(0)})")
        .join(", ");
    final prompt =
        "You are an AI assistant for a restaurant. Context: top categories are $summary. Do not summarize or repeat this data. Provide only a single, creative, 1-sentence actionable business advice on how to improve overall sales based on this split.";
    final result = await AiServices.generateAdvice(prompt);

    if (mounted) {
      setState(() {
        _aiAdvice = result;
        _isLoadingAi = false;
      });
    }
  }

  List<_CategorySplit> _computeFromReports(
    List<CategoryPerformanceReport> performance,
  ) {
    return performance
        .map(
          (c) => _CategorySplit(
            name: c.categoryName,
            revenue: c.totalRevenue,
            itemsSold: c.itemsSold,
          ),
        )
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          final categories = _computeFromReports(state.categoryPerformance);
          _fetchAiAdvice(categories);
        }
      },
      builder: (context, state) {
        final categories = state is ReportsLoaded
            ? _computeFromReports(state.categoryPerformance)
            : <_CategorySplit>[];

        final totalRevenue = categories.fold<double>(
          0.0,
          (sum, c) => sum + c.revenue,
        );

        return SingleChildScrollView(
          child: RepaintBoundary(
            key: widget.exportKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── Time Filter ───────────────────────────────
              _TimeFilterBar(
                selected: _selected,
                onSelected: _onTimeRangeSelected,
              ),
              const SizedBox(height: 24),

              // ── Insight Card ──────────────────────────────
              _CategoryMixInsightCard(
                categories: categories,
                totalRevenue: totalRevenue,
                aiAdvice: _aiAdvice,
                isLoadingAi: _isLoadingAi,
              ),
              const SizedBox(height: 24),

              // ── Chart + Table ─────────────────────────────
              if (state is ReportsLoading || state is ReportsInitial)
                const _LoadingCard()
              else if (state is ReportsError)
                _ErrorCard(message: state.message)
              else if (categories.isEmpty)
                const _EmptyCard(
                  icon: Icons.pie_chart_outline,
                  message: 'No paid orders for this period.',
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _RevenueDonutCard(
                          categories: categories,
                          totalRevenue: totalRevenue,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 7,
                        child: _CategoryPerformanceCard(
                          categories: categories,
                          totalRevenue: totalRevenue,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
          ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Time filter bar
// ─────────────────────────────────────────────────────────────
class _TimeFilterBar extends StatelessWidget {
  final _TimeRange selected;
  final ValueChanged<_TimeRange> onSelected;

  const _TimeFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: _TimeRange.values.map((r) {
        final isActive = r == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: isActive
                      ? null
                      : Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Insight Card
// ─────────────────────────────────────────────────────────────
class _CategoryMixInsightCard extends StatelessWidget {
  final List<_CategorySplit> categories;
  final double totalRevenue;
  final String? aiAdvice;
  final bool isLoadingAi;

  const _CategoryMixInsightCard({
    required this.categories,
    required this.totalRevenue,
    this.aiAdvice,
    this.isLoadingAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final String insightText;
    if (categories.isEmpty) {
      insightText =
          'No revenue data for this period yet. Select a broader time range or wait for orders.';
    } else {
      final top = categories.first;
      final topPct = totalRevenue > 0
          ? (top.revenue / totalRevenue * 100).toStringAsFixed(0)
          : '0';
      final others = categories.skip(1).take(2).map((c) => c.name).join(' & ');
      insightText =
          '${top.name} items account for $topPct% of your total revenue this period'
          '${others.isNotEmpty ? ', with $others making up the rest' : ''}.'
          ' ${categories.length > 1 ? "Consider bundling slow categories with top performers to boost overall ticket size." : ""}';
    }

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
                    Text(
                      insightText,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (totalRevenue > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Total: \$${totalRevenue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(color: cs.primary, width: 2.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI ADVICE & SUMMARY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isLoadingAi)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Text(
                              aiAdvice ?? 'No advice generated.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                                height: 1.5,
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
// Donut Chart Card — animated, colour-coded per category
// ─────────────────────────────────────────────────────────────

// Fixed palette for up to 8 categories
const _palette = [
  Color(0xFFE88328),
  Color(0xFF5B8FF9),
  Color(0xFF5AD8A6),
  Color(0xFFBBA598),
  Color(0xFFE96666),
  Color(0xFFA371F7),
  Color(0xFFF7BE71),
  Color(0xFF6BE6FF),
];

class _RevenueDonutCard extends StatelessWidget {
  final List<_CategorySplit> categories;
  final double totalRevenue;

  const _RevenueDonutCard({
    required this.categories,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Top 6 categories + "Other" if more
    final display = categories.take(6).toList();

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

          // Donut
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOut,
                    builder: (_, value, __) => CustomPaint(
                      size: const Size(220, 220),
                      painter: _MultiDonutPainter(
                        categories: display,
                        totalRevenue: totalRevenue,
                        progress: value,
                        strokeWidth: 22,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${totalRevenue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
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
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: display.asMap().entries.map((entry) {
              final color = _palette[entry.key % _palette.length];
              final c = entry.value;
              final pct = totalRevenue > 0
                  ? (c.revenue / totalRevenue * 100).toStringAsFixed(0)
                  : '0';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${c.name} ($pct%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MultiDonutPainter extends CustomPainter {
  final List<_CategorySplit> categories;
  final double totalRevenue;
  final double progress;
  final double strokeWidth;

  const _MultiDonutPainter({
    required this.categories,
    required this.totalRevenue,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2; // 12 o'clock

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final fraction = totalRevenue > 0 ? cat.revenue / totalRevenue : 0.0;
      final sweep = 2 * math.pi * fraction * progress;
      final color = _palette[i % _palette.length];

      // Arc
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweep, false, paint);

      // Glow
      final glowPaint = Paint()
        ..color = color.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.butt
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

      startAngle += sweep;
    }

    // Track (full grey circle underneath — draw first in the next frame via background)
  }

  @override
  bool shouldRepaint(covariant _MultiDonutPainter old) =>
      old.progress != progress || old.totalRevenue != totalRevenue;
}

// ─────────────────────────────────────────────────────────────
// Category Performance Table
// ─────────────────────────────────────────────────────────────
class _CategoryPerformanceCard extends StatelessWidget {
  final List<_CategorySplit> categories;
  final double totalRevenue;

  const _CategoryPerformanceCard({
    required this.categories,
    required this.totalRevenue,
  });

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
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                  Text(
                    '${categories.length} CATEGORIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Column headers
            Container(
              color: cs.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _hdr(context, 'CATEGORY NAME', flex: 30),
                  _hdr(context, 'ITEMS SOLD', flex: 20, align: TextAlign.right),
                  _hdr(context, 'REV SHARE', flex: 20, align: TextAlign.right),
                  _hdr(context, 'REVENUE', flex: 25, align: TextAlign.right),
                ],
              ),
            ),
            // Rows
            ...categories.asMap().entries.map((entry) {
              final color = _palette[entry.key % _palette.length];
              return _CategoryRow(
                split: entry.value,
                color: color,
                totalRevenue: totalRevenue,
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

class _CategoryRow extends StatefulWidget {
  final _CategorySplit split;
  final Color color;
  final double totalRevenue;
  final bool isLast;

  const _CategoryRow({
    required this.split,
    required this.color,
    required this.totalRevenue,
    required this.isLast,
  });

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = widget.totalRevenue > 0
        ? (widget.split.revenue / widget.totalRevenue * 100).toStringAsFixed(1)
        : '0.0';

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  // Category name + colour dot
                  Expanded(
                    flex: 30,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.split.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Items sold
                  Expanded(
                    flex: 20,
                    child: Text(
                      widget.split.itemsSold.toString(),
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
                          '$pct%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Revenue
                  Expanded(
                    flex: 25,
                    child: Text(
                      '\$${widget.split.revenue.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.color,
                      ),
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

// ─────────────────────────────────────────────────────────────
// Shared utility widgets
// ─────────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading data...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(
              Icons.warning_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
