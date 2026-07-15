import 'package:flutter/material.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/association_analysis_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/menu_analysis_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/revenue_split_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/staff_payments_tab.dart';

// ─────────────────────────────────────────────────────────────
// Period filter enum
// ─────────────────────────────────────────────────────────────
enum ReportPeriod { today, thisWeek, thisMonth, lastSixMonths }

extension ReportPeriodLabel on ReportPeriod {
  String get label => switch (this) {
        ReportPeriod.today => 'Today',
        ReportPeriod.thisWeek => 'This Week',
        ReportPeriod.thisMonth => 'This Month',
        ReportPeriod.lastSixMonths => 'Last 6 Months',
      };
}

// ─────────────────────────────────────────────────────────────
// Sub-tabs
// ─────────────────────────────────────────────────────────────
const _tabs = [
  'Menu Analysis',
  'Staff Payments',
  'Association Analysis',
  'Revenue Split',
];

// ─────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────
class ReportsAiPage extends StatefulWidget {
  const ReportsAiPage({super.key});

  @override
  State<ReportsAiPage> createState() => _ReportsAiPageState();
}

class _ReportsAiPageState extends State<ReportsAiPage> {
  int _selectedTab = 0;
  ReportPeriod _selectedPeriod = ReportPeriod.today;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top-right actions ────────────────────────────────────────
            const AdminTopBar(),
            const SizedBox(height: 24),

            // ── Page header + tabs row ───────────────────────────────────
            _PageHeader(
              selectedTab: _selectedTab,
              onTabSelected: (i) => setState(() => _selectedTab = i),
            ),
            const SizedBox(height: 20),

            // ── Period filter bar ────────────────────────────────────────
            _PeriodFilterBar(
              selected: _selectedPeriod,
              onSelected: (p) => setState(() => _selectedPeriod = p),
            ),
            const SizedBox(height: 20),

            // ── Content — switches per tab ───────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: const [
                  // Tab 0 — Menu Analysis
                  MenuAnalysisTab(),

                  // Tab 1 — Staff Payments
                  StaffPaymentsTab(),

                  // Tab 2 — Association Analysis
                  AssociationAnalysisTab(),

                  // Tab 3 — Revenue Split
                  RevenueSplitTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Period filter bar
// ─────────────────────────────────────────────────────────────
class _PeriodFilterBar extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;

  const _PeriodFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReportPeriod.values
            .map((p) => _PeriodPill(
                  period: p,
                  isActive: p == selected,
                  onTap: () => onSelected(p),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single period pill
// ─────────────────────────────────────────────────────────────
class _PeriodPill extends StatefulWidget {
  final ReportPeriod period;
  final bool isActive;
  final VoidCallback onTap;

  const _PeriodPill({
    required this.period,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PeriodPill> createState() => _PeriodPillState();
}

class _PeriodPillState extends State<_PeriodPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isActive
                ? cs.primary
                : _hovered
                    ? cs.surfaceContainerHigh
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.period.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  widget.isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
              color: widget.isActive
                  ? Colors.white
                  : _hovered
                      ? cs.onSurface
                      : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Page header: title + sub-tabs + export button
// ─────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const _PageHeader({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Title + tabs column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERATIONAL INTELLIGENCE & REPORTING',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 12),
              // Sub-tabs row
              Row(
                children: List.generate(_tabs.length, (i) {
                  final isActive = i == selectedTab;
                  return GestureDetector(
                    onTap: () => onTabSelected(i),
                    child: _SubTab(label: _tabs[i], isActive: isActive),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Export to PDF button
        const _ExportButton(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-tab pill
// ─────────────────────────────────────────────────────────────
class _SubTab extends StatefulWidget {
  final String label;
  final bool isActive;

  const _SubTab({required this.label, required this.isActive});

  @override
  State<_SubTab> createState() => _SubTabState();
}

class _SubTabState extends State<_SubTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.isActive ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: widget.isActive
                ? cs.primary
                : _hovered
                    ? cs.onSurface
                    : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Export to PDF button
// ─────────────────────────────────────────────────────────────
class _ExportButton extends StatefulWidget {
  const _ExportButton();

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? cs.surfaceContainerHigh : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export to PDF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.download_outlined, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
