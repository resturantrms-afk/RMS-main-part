import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_event.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_state.dart';
import 'package:rmss/features/admin/models/reports/association_report.dart';
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
// Data models
// ─────────────────────────────────────────────────────────────
class _ItemPairing {
  final List<String> items;
  final int coOccurrence;
  final double frequency; // relative (0–1)

  const _ItemPairing({
    required this.items,
    required this.coOccurrence,
    required this.frequency,
  });

  String get label => items.join(' + ');
}

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class AssociationAnalysisTab extends StatefulWidget {
  final GlobalKey? exportKey;
  
  const AssociationAnalysisTab({super.key, this.exportKey});

  @override
  State<AssociationAnalysisTab> createState() => _AssociationAnalysisTabState();
}

class _AssociationAnalysisTabState extends State<AssociationAnalysisTab> {
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

    context.read<ReportsBloc>().add(LoadReports(
      startDate: startDate,
      endDate: endDate,
    ));
  }

  void _onTimeRangeSelected(_TimeRange r) {
    setState(() {
      _selected = r;
      _aiAdvice = null;
    });
    _loadDataFor(r);
  }

  Future<void> _fetchAiAdvice(List<_ItemPairing> pairings) async {
    if (pairings.isEmpty || _aiAdvice != null || _isLoadingAi) return;
    
    setState(() => _isLoadingAi = true);
    final summary = pairings.take(3).map((e) => "${e.items.join(' & ')} (${e.coOccurrence})").join(", ");
    final prompt = "You are an AI assistant for a restaurant. Context: top item groups bought together are $summary. Do not summarize or repeat this data. Provide only a single, creative, 1-sentence actionable business advice on how to improve bundling or upselling based on these item groups.";
    final result = await AiServices.generateAdvice(prompt);
    
    if (mounted) {
      setState(() {
        _aiAdvice = result;
        _isLoadingAi = false;
      });
    }
  }

  List<_ItemPairing> _computeFromReports(AssociationAlgorithmReport report) {
    final pairs = report.frequentlyBoughtTogether;
    if (pairs.isEmpty) return [];

    final maxFreq = pairs.map((e) => e.frequency).reduce((a, b) => a > b ? a : b);
    
    return pairs.map((e) {
      return _ItemPairing(
        items: e.items,
        coOccurrence: e.frequency,
        frequency: maxFreq == 0 ? 0 : e.frequency / maxFreq,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          final pairings = _computeFromReports(state.associationReport);
          _fetchAiAdvice(pairings);
        }
      },
      builder: (context, state) {
        final pairings = state is ReportsLoaded
            ? _computeFromReports(state.associationReport)
            : <_ItemPairing>[];

        final topPair = pairings.isNotEmpty ? pairings.first : null;

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

              // ── AI Insight ────────────────────────────────────
              _AiAssociationInsightCard(
                topPair: topPair,
                aiAdvice: _aiAdvice,
                isLoadingAi: _isLoadingAi,
              ),
              const SizedBox(height: 24),

              // ── Bar Chart ─────────────────────────────────────
              if (state is ReportsLoading || state is ReportsInitial)
                const _LoadingCard()
              else if (state is ReportsError)
                _ErrorCard(message: state.message)
              else if (pairings.isEmpty)
                const _EmptyCard(
                  icon: Icons.link_outlined,
                  message:
                      'Not enough data yet. Pairings appear when multiple items are ordered together.',
                )
              else ...[
                _TopPairingsCard(pairings: pairings),
                const SizedBox(height: 24),
                _AssociationTable(pairings: pairings),
              ],

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
// AI Association Insight Card
// ─────────────────────────────────────────────────────────────
class _AiAssociationInsightCard extends StatelessWidget {
  final _ItemPairing? topPair;
  final String? aiAdvice;
  final bool isLoadingAi;

  const _AiAssociationInsightCard({
    this.topPair,
    this.aiAdvice,
    this.isLoadingAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final insight = topPair != null
        ? "Customers frequently order these items together: ${topPair!.items.join(', ')} (${topPair!.coOccurrence} co-occurrences). Consider creating a bundle to boost ticket size."
        : 'No pairing data available for this period yet.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
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
                      color: cs.outlineVariant.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(Icons.auto_awesome_outlined,
                    size: 26, color: cs.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Association Insight',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insight,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
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
                              child: CircularProgressIndicator(strokeWidth: 2)
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
// Top Item Pairings Bar Chart
// ─────────────────────────────────────────────────────────────
class _TopPairingsCard extends StatelessWidget {
  final List<_ItemPairing> pairings;
  const _TopPairingsCard({required this.pairings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top5 = pairings.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Item Pairings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: cs.primary.withValues(alpha: 0.5),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PAIRING FREQUENCY',
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
          const SizedBox(height: 28),
          ...top5.map((p) => _PairingBar(pairing: p)),
        ],
      ),
    );
  }
}

class _PairingBar extends StatelessWidget {
  final _ItemPairing pairing;
  const _PairingBar({required this.pairing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: Text(
              pairing.label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pairing.frequency),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (_, value, __) {
                    return SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Container(
                            width: trackWidth,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          Container(
                            width: trackWidth * value,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              '${pairing.coOccurrence} Orders',
              textAlign: TextAlign.right,
              style:
                  TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Association Table
// ─────────────────────────────────────────────────────────────
class _AssociationTable extends StatelessWidget {
  final List<_ItemPairing> pairings;
  const _AssociationTable({required this.pairings});

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
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: cs.surfaceContainer.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Item Association Table',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: cs.surfaceContainerHigh,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _hdr(context, 'ITEMS BOUGHT TOGETHER', flex: 50),
                  _hdr(context, 'CO-OCCURRENCE',
                      flex: 25, align: TextAlign.center),
                  _hdr(context, 'STRENGTH',
                      flex: 25, align: TextAlign.center),
                ],
              ),
            ),
            ...pairings.asMap().entries.map((entry) {
              return _AssocRow(
                pairing: entry.value,
                isLast: entry.key == pairings.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _hdr(BuildContext context, String label,
      {int flex = 1, TextAlign align = TextAlign.left}) {
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

class _AssocRow extends StatefulWidget {
  final _ItemPairing pairing;
  final bool isLast;
  const _AssocRow({required this.pairing, required this.isLast});

  @override
  State<_AssocRow> createState() => _AssocRowState();
}

class _AssocRowState extends State<_AssocRow> {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    flex: 50,
                    child: Text(
                      widget.pairing.items.join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      widget.pairing.coOccurrence.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      '${(widget.pairing.frequency * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
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
                color: Theme.of(context).colorScheme.primary, strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Loading data...',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
            Icon(Icons.warning_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
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
            Icon(icon,
                size: 56,
                color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(message,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
