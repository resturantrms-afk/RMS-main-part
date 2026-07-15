import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────
enum StaffPaymentRole { admin, cashier }

class StaffPaymentRecord {
  final String initials;
  final String name;
  final StaffPaymentRole role;
  final int ordersProcessed;
  final double revenueCollected;

  const StaffPaymentRecord({
    required this.initials,
    required this.name,
    required this.role,
    required this.ordersProcessed,
    required this.revenueCollected,
  });
}

const _mockPayments = [
  StaffPaymentRecord(
    initials: 'AS',
    name: 'Admin Sarah',
    role: StaffPaymentRole.admin,
    ordersProcessed: 112,
    revenueCollected: 2450.00,
  ),
  StaffPaymentRecord(
    initials: 'CM',
    name: 'Cashier Marcus',
    role: StaffPaymentRole.cashier,
    ordersProcessed: 84,
    revenueCollected: 1280.50,
  ),
  StaffPaymentRecord(
    initials: 'AJ',
    name: 'Admin John',
    role: StaffPaymentRole.admin,
    ordersProcessed: 45,
    revenueCollected: 890.25,
  ),
  StaffPaymentRecord(
    initials: 'CE',
    name: 'Cashier Elena',
    role: StaffPaymentRole.cashier,
    ordersProcessed: 62,
    revenueCollected: 920.00,
  ),
];

// ─────────────────────────────────────────────────────────────
// Tab widget (the scrollable body for the Staff Payments tab)
// ─────────────────────────────────────────────────────────────
class StaffPaymentsTab extends StatelessWidget {
  const StaffPaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accountability Summary card
          const _AccountabilitySummaryCard(),
          const SizedBox(height: 24),

          // Payment Processing Ledger table
          _PaymentLedgerTable(records: _mockPayments),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Accountability Summary card
// ─────────────────────────────────────────────────────────────
class _AccountabilitySummaryCard extends StatelessWidget {
  const _AccountabilitySummaryCard();

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
          // Decorative glow — top right
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
          // Content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shield / accountability icon
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
                  Icons.account_balance_wallet_outlined,
                  size: 26,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 20),

              // Text
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
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Payment Audit: Admin Sarah has processed the majority of today\'s revenue (',
                          ),
                          TextSpan(
                            text: '\$2,450',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '). All logged payments match the digital order records. Transaction speeds are consistent across all cashiers, indicating a smooth checkout process.',
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
// Payment Processing Ledger table
// ─────────────────────────────────────────────────────────────
class _PaymentLedgerTable extends StatelessWidget {
  final List<StaffPaymentRecord> records;

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
            // ── Toolbar ────────────────────────────────────────
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
                    'Payment Processing Ledger',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Filter button
                  _ToolbarIconBtn(icon: Icons.filter_list_rounded),
                  const SizedBox(width: 8),
                  // More-options button
                  _ToolbarIconBtn(icon: Icons.more_vert_rounded),
                ],
              ),
            ),

            // ── Column headers ─────────────────────────────────
            Container(
              color: cs.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _headerCell(context, 'STAFF MEMBER', flex: 30),
                  _headerCell(context, 'ROLE', flex: 20),
                  _headerCell(
                    context,
                    'TOTAL ORDERS PROCESSED',
                    flex: 25,
                    align: TextAlign.right,
                  ),
                  _headerCell(
                    context,
                    'TOTAL REVENUE COLLECTED',
                    flex: 25,
                    align: TextAlign.right,
                  ),
                ],
              ),
            ),

            // ── Rows ───────────────────────────────────────────
            ...records.asMap().entries.map((entry) {
              final i = entry.key;
              final record = entry.value;
              return _LedgerRow(
                record: record,
                isLast: i == records.length - 1,
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

// ─────────────────────────────────────────────────────────────
// Toolbar icon button (filter / more)
// ─────────────────────────────────────────────────────────────
class _ToolbarIconBtn extends StatefulWidget {
  final IconData icon;
  const _ToolbarIconBtn({required this.icon});

  @override
  State<_ToolbarIconBtn> createState() => _ToolbarIconBtnState();
}

class _ToolbarIconBtnState extends State<_ToolbarIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _hovered ? cs.surfaceContainerHighest : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(widget.icon, size: 16, color: cs.onSurfaceVariant),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single ledger row
// ─────────────────────────────────────────────────────────────
class _LedgerRow extends StatefulWidget {
  final StaffPaymentRecord record;
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
    final isAdmin = widget.record.role == StaffPaymentRole.admin;

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Staff member — avatar + name
                  Expanded(
                    flex: 30,
                    child: Row(
                      children: [
                        // Initials avatar
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
                        Text(
                          widget.record.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Role badge
                  Expanded(
                    flex: 20,
                    child: _RoleBadge(isAdmin: isAdmin),
                  ),

                  // Orders processed
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

                  // Revenue collected
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

// ─────────────────────────────────────────────────────────────
// Role badge chip
// ─────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final bool isAdmin;
  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = isAdmin
        ? cs.primary.withValues(alpha: 0.10)
        : cs.surfaceContainerHigh;
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
        isAdmin ? 'ADMIN' : 'CASHIER',
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
