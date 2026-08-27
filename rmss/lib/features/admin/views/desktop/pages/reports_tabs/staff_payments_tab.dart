import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_event.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_state.dart';
import 'package:rmss/features/admin/models/reports/payment_processing_ledger.dart';
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
// Computed ledger record
// ─────────────────────────────────────────────────────────────
class _LedgerEntry {
  final String userId;
  final String name;
  final String role;
  final String initials;
  final int ordersProcessed;
  final double revenueCollected;

  const _LedgerEntry({
    required this.userId,
    required this.name,
    required this.role,
    required this.initials,
    required this.ordersProcessed,
    required this.revenueCollected,
  });
}

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class StaffPaymentsTab extends StatefulWidget {
  final GlobalKey? exportKey;
  
  const StaffPaymentsTab({super.key, this.exportKey});

  @override
  State<StaffPaymentsTab> createState() => _StaffPaymentsTabState();
}

class _StaffPaymentsTabState extends State<StaffPaymentsTab> {
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
      _aiAdvice = null; // reset advice when time changes
    });
    _loadDataFor(r);
  }

  Future<void> _fetchAiAdvice(List<_LedgerEntry> ledger) async {
    if (ledger.isEmpty || _aiAdvice != null || _isLoadingAi) return;
    
    setState(() => _isLoadingAi = true);
    final summary = ledger.map((e) => "${e.name}: \$${e.revenueCollected.toStringAsFixed(0)}").join(", ");
    final prompt = "You are an AI assistant for a restaurant. Context: staff performance is $summary. Do not summarize or repeat this data. Provide only a single, creative, 1-sentence actionable business advice on how to motivate staff or optimize scheduling.";
    final result = await AiServices.generateAdvice(prompt);
    
    if (mounted) {
      setState(() {
        _aiAdvice = result;
        _isLoadingAi = false;
      });
    }
  }

  List<_LedgerEntry> _computeFromReports(List<PaymentProcessingLedger> ledgers) {
    return ledgers.map((l) {
      String name = l.userName;
      String role = l.userRole;
      String initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : '??';
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }

      return _LedgerEntry(
        userId: l.userId,
        name: name,
        role: role,
        initials: initials,
        ordersProcessed: l.totalOrdersProcessed,
        revenueCollected: l.totalRevenueCollected,
      );
    }).toList()
      ..sort((a, b) => b.revenueCollected.compareTo(a.revenueCollected));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          final ledger = _computeFromReports(state.paymentLedgers);
          _fetchAiAdvice(ledger);
        }
      },
      builder: (context, state) {
        final ledger = state is ReportsLoaded
            ? _computeFromReports(state.paymentLedgers)
            : <_LedgerEntry>[];

        final topStaff = ledger.isNotEmpty ? ledger.first : null;
        final totalRevenue = ledger.fold<double>(
            0.0, (sum, e) => sum + e.revenueCollected);

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

              // ── Accountability Summary ────────────────────
              _AccountabilitySummaryCard(
                topStaff: topStaff,
                totalRevenue: totalRevenue,
                totalOrders: ledger.fold(0, (s, e) => s + e.ordersProcessed),
                aiAdvice: _aiAdvice,
                isLoadingAi: _isLoadingAi,
              ),
              const SizedBox(height: 24),

              // ── Ledger Table ──────────────────────────────
              if (state is ReportsLoading || state is ReportsInitial)
                const _LoadingCard()
              else if (state is ReportsError)
                _ErrorCard(message: state.message)
              else if (ledger.isEmpty)
                const _EmptyCard(
                  icon: Icons.account_balance_wallet_outlined,
                  message: 'No payment activity for this period.',
                )
              else
                _PaymentLedgerTable(records: ledger),

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
// Accountability summary
// ─────────────────────────────────────────────────────────────
class _AccountabilitySummaryCard extends StatelessWidget {
  final _LedgerEntry? topStaff;
  final double totalRevenue;
  final int totalOrders;
  final String? aiAdvice;
  final bool isLoadingAi;

  const _AccountabilitySummaryCard({
    this.topStaff,
    required this.totalRevenue,
    required this.totalOrders,
    this.aiAdvice,
    this.isLoadingAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topText = topStaff != null
        ? '${topStaff!.name} has processed the most revenue this period (\$${topStaff!.revenueCollected.toStringAsFixed(2)})'
        : 'No payment data for this period.';

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
                child: Icon(Icons.account_balance_wallet_outlined,
                    size: 26, color: cs.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accountability Summary',
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
                            color: cs.onSurfaceVariant),
                        children: [
                          TextSpan(text: 'Payment Audit: $topText. '),
                          TextSpan(
                            text: '$totalOrders orders',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface),
                          ),
                          const TextSpan(text: ' totalling '),
                          TextSpan(
                            text: '\$${totalRevenue.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: cs.primary),
                          ),
                          const TextSpan(text: ' processed this period.'),
                        ],
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
// Ledger table
// ─────────────────────────────────────────────────────────────
class _PaymentLedgerTable extends StatelessWidget {
  final List<_LedgerEntry> records;

  const _PaymentLedgerTable({required this.records});

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
            // Toolbar
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
                    'Payment Processing Ledger',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${records.length} STAFF',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _hdr(context, 'STAFF MEMBER', flex: 30),
                  _hdr(context, 'ROLE', flex: 20),
                  _hdr(context, 'TOTAL ORDERS PROCESSED',
                      flex: 25, align: TextAlign.right),
                  _hdr(context, 'TOTAL REVENUE COLLECTED',
                      flex: 25, align: TextAlign.right),
                ],
              ),
            ),
            // Rows
            ...records.asMap().entries.map((entry) {
              return _LedgerRow(
                record: entry.value,
                isLast: entry.key == records.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _hdr(BuildContext context, String label,
      {int flex = 1, TextAlign align = TextAlign.left}) {
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

class _LedgerRow extends StatefulWidget {
  final _LedgerEntry record;
  final bool isLast;

  const _LedgerRow({required this.record, required this.isLast});

  @override
  State<_LedgerRow> createState() => _LedgerRowState();
}

class _LedgerRowState extends State<_LedgerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAdmin = widget.record.role.toLowerCase().contains('admin');

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
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Name + avatar
                  Expanded(
                    flex: 30,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? cs.primary.withValues(alpha: 0.15)
                                : cs.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isAdmin
                                  ? cs.primary.withValues(alpha: 0.4)
                                  : cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.record.initials,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isAdmin
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.record.name,
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
                  // Role badge
                  Expanded(flex: 20, child: _RoleBadge(isAdmin: isAdmin, role: widget.record.role)),
                  // Orders
                  Expanded(
                    flex: 25,
                    child: Text(
                      widget.record.ordersProcessed.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  // Revenue
                  Expanded(
                    flex: 25,
                    child: Text(
                      '\$${widget.record.revenueCollected.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
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

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;
  final String role;
  const _RoleBadge({required this.isAdmin, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor =
        isAdmin ? cs.primary.withValues(alpha: 0.10) : cs.surfaceContainerHigh;
    final textColor = isAdmin ? cs.primary : cs.onSurfaceVariant;
    final borderColor = isAdmin
        ? cs.primary.withValues(alpha: 0.25)
        : cs.outlineVariant.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
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
