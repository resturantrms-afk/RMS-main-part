import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────
class ItemPairing {
  final String label;
  final int orders;
  final double frequency; // 0.0 – 1.0

  const ItemPairing({
    required this.label,
    required this.orders,
    required this.frequency,
  });
}

class AssociationRecord {
  final String primaryItem;
  final String associatedItem;
  final int coOccurrence;
  final int strengthPercent;

  const AssociationRecord({
    required this.primaryItem,
    required this.associatedItem,
    required this.coOccurrence,
    required this.strengthPercent,
  });
}

const _topPairings = [
  ItemPairing(
    label: 'Charcoal Ribeye + Smoked Old Fashioned',
    orders: 142,
    frequency: 0.85,
  ),
  ItemPairing(
    label: 'Smoked Brisket + Craft Amber Ale',
    orders: 118,
    frequency: 0.72,
  ),
  ItemPairing(
    label: 'Wood-Fired Pizza + Caesar Salad',
    orders: 95,
    frequency: 0.58,
  ),
  ItemPairing(
    label: 'Burnt Ends + Sweet Cornbread',
    orders: 88,
    frequency: 0.52,
  ),
];

const _associations = [
  AssociationRecord(
    primaryItem: 'Charcoal Ribeye',
    associatedItem: 'Smoked Old Fashioned',
    coOccurrence: 142,
    strengthPercent: 85,
  ),
  AssociationRecord(
    primaryItem: 'Smoked Brisket',
    associatedItem: 'Craft Amber Ale',
    coOccurrence: 118,
    strengthPercent: 72,
  ),
  AssociationRecord(
    primaryItem: 'Wood-Fired Pizza',
    associatedItem: 'Caesar Salad',
    coOccurrence: 95,
    strengthPercent: 58,
  ),
  AssociationRecord(
    primaryItem: 'Burnt Ends',
    associatedItem: 'Sweet Cornbread',
    coOccurrence: 88,
    strengthPercent: 52,
  ),
  AssociationRecord(
    primaryItem: 'Grilled Asparagus',
    associatedItem: 'Lemon Butter Sauce',
    coOccurrence: 74,
    strengthPercent: 92,
  ),
];

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class AssociationAnalysisTab extends StatelessWidget {
  const AssociationAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI insight card
          const _AiAssociationInsightCard(),
          const SizedBox(height: 24),

          // Top pairings bar chart
          _TopPairingsCard(pairings: _topPairings),
          const SizedBox(height: 24),

          // Association table
          _AssociationTable(records: _associations),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI Association Insight Card
// ─────────────────────────────────────────────────────────────
class _AiAssociationInsightCard extends StatelessWidget {
  const _AiAssociationInsightCard();

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
          // Decorative glow
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
          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // auto_awesome icon circle
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
                  Icons.auto_awesome_outlined,
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
                      'AI Association Insight',
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
                          TextSpan(
                            text: 'AI Association Analysis: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                          const TextSpan(text: 'Customers who order '),
                          TextSpan(
                            text: "'Charcoal Ribeye'",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(text: ' are '),
                          TextSpan(
                            text: '85% more likely',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(text: ' to also order '),
                          TextSpan(
                            text: "'Smoked Old Fashioned'",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(text: '. Consider a '),
                          TextSpan(
                            text: "'Hearth Special'",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: cs.primary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' bundle to increase average ticket size and enhance the guest experience.',
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
// Top Item Pairings — horizontal bar chart
// ─────────────────────────────────────────────────────────────
class _TopPairingsCard extends StatelessWidget {
  final List<ItemPairing> pairings;
  const _TopPairingsCard({required this.pairings});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
              // Legend dot
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
                          blurRadius: 6,
                        ),
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

          // Bars
          ...pairings.map((p) => _PairingBar(pairing: p)),
        ],
      ),
    );
  }
}

class _PairingBar extends StatelessWidget {
  final ItemPairing pairing;
  const _PairingBar({required this.pairing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Label — fixed portion on the left
          SizedBox(
            width: 260,
            child: Text(
              pairing.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),

          // Bar — stretches to fill remaining space
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
                          // Track
                          Container(
                            width: trackWidth,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          // Animated fill
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

          // Order count — right side
          SizedBox(
            width: 72,
            child: Text(
              '${pairing.orders} Orders',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Item Association Table
// ─────────────────────────────────────────────────────────────
class _AssociationTable extends StatelessWidget {
  final List<AssociationRecord> records;
  const _AssociationTable({required this.records});

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

            // ── Column headers ─────────────────────────────────
            Container(
              color: cs.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _hdr(context, 'PRIMARY ITEM', flex: 25),
                  _hdr(context, 'ASSOCIATED ITEM', flex: 25),
                  _hdr(
                    context,
                    'CO-OCCURRENCE',
                    flex: 20,
                    align: TextAlign.center,
                  ),
                  _hdr(
                    context,
                    'ASSOCIATION STRENGTH',
                    flex: 20,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Rows ───────────────────────────────────────────
            ...records.asMap().entries.map((entry) {
              return _AssociationRow(
                record: entry.value,
                isLast: entry.key == records.length - 1,
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
// Single association row — flex updated for 4-col layout
// ─────────────────────────────────────────────────────────────
class _AssociationRow extends StatefulWidget {
  final AssociationRecord record;
  final bool isLast;

  const _AssociationRow({required this.record, required this.isLast});

  @override
  State<_AssociationRow> createState() => _AssociationRowState();
}

class _AssociationRowState extends State<_AssociationRow> {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  // Primary item
                  Expanded(
                    flex: 22,
                    child: Text(
                      widget.record.primaryItem,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  // Associated item
                  Expanded(
                    flex: 22,
                    child: Text(
                      widget.record.associatedItem,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                    ),
                  ),

                  // Co-occurrence count
                  Expanded(
                    flex: 20,
                    child: Text(
                      widget.record.coOccurrence.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  // Association strength
                  Expanded(
                    flex: 20,
                    child: Text(
                      '${widget.record.strengthPercent}%',
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
