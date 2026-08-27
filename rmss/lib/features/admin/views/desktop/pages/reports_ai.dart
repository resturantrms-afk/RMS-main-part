import 'package:flutter/material.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/association_analysis_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/menu_analysis_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/revenue_split_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/staff_payments_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/ai_data_mining_tab.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/pdf_export_service.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/orders_report_tab.dart';

// ─────────────────────────────────────────────────────────────
// Sub-tabs
// ─────────────────────────────────────────────────────────────
const _tabs = [
  'Orders Report',
  'Menu Analysis',
  'Staff Payments',
  'Association Analysis',
  'Revenue Split',
  'AI Data Mining',
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
  final List<GlobalKey> _exportKeys = List.generate(6, (_) => GlobalKey());
  bool _isExporting = false;

  Future<void> _handleExport() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final fileName = _tabs[_selectedTab].replaceAll(' ', '_');
      await PdfExportService.exportWidgetToPdf(_exportKeys[_selectedTab], fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export not supported for this tab yet or failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

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
              onExport: _handleExport,
              isExporting: _isExporting,
            ),
            const SizedBox(height: 20),

            // ── Content — switches per tab ───────────────────────────────
            Expanded(
              child: [
                // Tab 0 — Orders Report
                OrdersReportTab(exportKey: _exportKeys[0]),
                // Tab 1 — Menu Analysis
                MenuAnalysisTab(exportKey: _exportKeys[1]),
                // Tab 2 — Staff Payments
                StaffPaymentsTab(exportKey: _exportKeys[2]),
                // Tab 3 — Association Analysis
                AssociationAnalysisTab(exportKey: _exportKeys[3]),
                // Tab 4 — Revenue Split
                RevenueSplitTab(exportKey: _exportKeys[4]),
                // Tab 5 - AI Data Mining
                AiDataMiningTab(exportKey: _exportKeys[5]),
              ][_selectedTab],
            ),
          ],
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
  final VoidCallback onExport;
  final bool isExporting;

  const _PageHeader({
    required this.selectedTab,
    required this.onTabSelected,
    required this.onExport,
    required this.isExporting,
  });

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
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onTabSelected(i),
                      child: _SubTab(label: _tabs[i], isActive: isActive),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Export to PDF button
        _ExportButton(
          onPressed: onExport,
          isLoading: isExporting,
        ),
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
  final VoidCallback onPressed;
  final bool isLoading;

  const _ExportButton({required this.onPressed, required this.isLoading});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? cs.surfaceContainerHigh : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isLoading ? 'EXPORTING...' : 'Export to PDF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
              )
            else
              Icon(Icons.download_outlined, size: 16, color: cs.primary),
          ],
        ),
        ),
      ),
    );
  }
}
