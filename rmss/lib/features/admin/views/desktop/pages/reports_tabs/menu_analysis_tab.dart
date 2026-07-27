import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_event.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_state.dart';
import 'package:rmss/features/admin/models/reports/item_importance_report.dart';
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
enum ItemStatus { highPerforming, underperforming, normal }

class _MenuItemReport {
  final String name;
  final String category;
  final int unitsSold;
  final double revenue;
  final ItemStatus status;

  const _MenuItemReport({
    required this.name,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class MenuAnalysisTab extends StatefulWidget {
  final GlobalKey? exportKey;

  const MenuAnalysisTab({super.key, this.exportKey});

  @override
  State<MenuAnalysisTab> createState() => _MenuAnalysisTabState();
}

class _MenuAnalysisTabState extends State<MenuAnalysisTab> {
  _TimeRange _selected = _TimeRange.today;
  String? _aiAdvice;
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    // Dispatch initial load
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

  Future<void> _fetchAiAdvice(List<_MenuItemReport> items) async {
    if (items.isEmpty || _aiAdvice != null || _isLoadingAi) return;

    setState(() => _isLoadingAi = true);
    final top = items.first;
    final under = items
        .where((i) => i.status == ItemStatus.underperforming)
        .firstOrNull;
    final summary =
        "top item: ${top.name} (${top.unitsSold} units)${under != null ? ', underperforming: ${under.name}' : ''}";
    final prompt =
        "You are an AI assistant for a restaurant. Context: $summary. Do not repeat or summarize these stats. Provide only a single, creative, 1-sentence actionable business advice on how to capitalize on the top item or improve the underperforming one.";
    final result = await AiServices.generateAdvice(prompt);

    if (mounted) {
      setState(() {
        _aiAdvice = result;
        _isLoadingAi = false;
      });
    }
  }

  List<_MenuItemReport> _computeFromReports(
    List<ItemImportanceReport> reports,
  ) {
    return reports.map((r) {
      ItemStatus s = ItemStatus.normal;
      if (r.status == ItemPerformanceStatus.highPerforming) {
        s = ItemStatus.highPerforming;
      } else if (r.status == ItemPerformanceStatus.underPerforming) {
        s = ItemStatus.underperforming;
      }
      return _MenuItemReport(
        name: r.dishName,
        category: r.firstCategory,
        unitsSold: r.unitsSold,
        revenue: r.totalRevenue,
        status: s,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          final items = _computeFromReports(state.itemImportanceReports);
          _fetchAiAdvice(items);
        }
      },
      builder: (context, state) {
        final items = state is ReportsLoaded
            ? _computeFromReports(state.itemImportanceReports)
            : <_MenuItemReport>[];

        final topItem = items.isNotEmpty ? items.first : null;
        final underItems = items
            .where((i) => i.status == ItemStatus.underperforming)
            .toList();

        return SingleChildScrollView(
          child: RepaintBoundary(
            key: widget.exportKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Time Filter ───────────────────────────────────
                  _TimeFilterBar(
                    selected: _selected,
                    onSelected: _onTimeRangeSelected,
                  ),
                  const SizedBox(height: 24),

                  // ── AI Insight Card ───────────────────────────────
                  _AiInsightCard(
                    topItem: topItem,
                    underItem: underItems.firstOrNull,
                    aiAdvice: _aiAdvice,
                    isLoadingAi: _isLoadingAi,
                  ),
                  const SizedBox(height: 24),

                  // ── Table ─────────────────────────────────────────
                  if (state is ReportsLoading || state is ReportsInitial)
                    const _LoadingCard()
                  else if (state is ReportsError)
                    _ErrorCard(message: state.message)
                  else if (items.isEmpty)
                    const _EmptyCard(
                      icon: Icons.restaurant_menu_outlined,
                      message: 'No paid orders for this period yet.',
                    )
                  else
                    _RankedItemsTable(items: items),

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
// Time filter bar (shared style)
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
// AI Insight Card
// ─────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final _MenuItemReport? topItem;
  final _MenuItemReport? underItem;
  final String? aiAdvice;
  final bool isLoadingAi;

  const _AiInsightCard({
    this.topItem,
    this.underItem,
    this.aiAdvice,
    this.isLoadingAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final topText = topItem != null
        ? '${topItem!.name} (${topItem!.unitsSold} units · \$${topItem!.revenue.toStringAsFixed(0)})'
        : 'No data yet';
    final underText = underItem != null
        ? '${underItem!.name} is underperforming with only ${underItem!.unitsSold} units sold.'
        : 'No underperforming items detected.';

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
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.08),
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
                  Icons.psychology_outlined,
                  size: 28,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Operational Insight',
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
                          const TextSpan(text: 'Top earner this period: '),
                          TextSpan(
                            text: topText,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          TextSpan(text: '. $underText'),
                        ],
                      ),
                    ),
                    if (underItem != null ||
                        aiAdvice != null ||
                        isLoadingAi) ...[
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
                              'RECOMMENDATION',
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Text(
                                aiAdvice ??
                                    'Consider a promotional bundle or recipe change for underperforming items.',
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
// Ranked Items Table
// ─────────────────────────────────────────────────────────────
class _RankedItemsTable extends StatelessWidget {
  final List<_MenuItemReport> items;

  const _RankedItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
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
                    'Ranked Item Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${items.length} ITEMS',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  _headerCell(context, 'ITEM NAME', flex: 30),
                  _headerCell(context, 'CATEGORY', flex: 20),
                  _headerCell(
                    context,
                    'UNITS SOLD',
                    flex: 18,
                    align: TextAlign.right,
                  ),
                  _headerCell(
                    context,
                    'TOTAL REVENUE',
                    flex: 18,
                    align: TextAlign.right,
                  ),
                  _headerCell(
                    context,
                    'STATUS',
                    flex: 18,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Rows
            ...items.asMap().entries.map((entry) {
              return _ItemRow(
                item: entry.value,
                isLast: entry.key == items.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    BuildContext context,
    String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ItemRow extends StatefulWidget {
  final _MenuItemReport item;
  final bool isLast;

  const _ItemRow({required this.item, required this.isLast});

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 30,
                    child: Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: Text(
                      widget.item.category,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 18,
                    child: Text(
                      widget.item.unitsSold.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 18,
                    child: Text(
                      '\$${widget.item.revenue.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 18,
                    child: Center(
                      child: _StatusBadge(status: widget.item.status),
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

class _StatusBadge extends StatelessWidget {
  final ItemStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const highColor = Color(0xFF4ade80);
    final lowColor = cs.error;
    final normalColor = cs.onSurfaceVariant;

    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final String label;

    switch (status) {
      case ItemStatus.highPerforming:
        bgColor = highColor.withValues(alpha: 0.10);
        textColor = highColor;
        borderColor = highColor.withValues(alpha: 0.20);
        label = 'HIGH PERFORMING';
        break;
      case ItemStatus.underperforming:
        bgColor = lowColor.withValues(alpha: 0.10);
        textColor = lowColor;
        borderColor = lowColor.withValues(alpha: 0.20);
        label = 'UNDERPERFORMING';
        break;
      case ItemStatus.normal:
        bgColor = normalColor.withValues(alpha: 0.08);
        textColor = normalColor;
        borderColor = normalColor.withValues(alpha: 0.15);
        label = 'NORMAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: textColor,
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(Icons.warning_rounded, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(icon, size: 56, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
