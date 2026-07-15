import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────
enum ItemStatus { highPerforming, underperforming }

class MenuItemReport {
  final String name;
  final String category;
  final int unitsSold;
  final double revenue;
  final ItemStatus status;

  const MenuItemReport({
    required this.name,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.status,
  });
}

const _mockItems = [
  MenuItemReport(
    name: 'Spicy Zinger',
    category: 'Mains',
    unitsSold: 142,
    revenue: 1200,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Classic Fries',
    category: 'Sides',
    unitsSold: 210,
    revenue: 840,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Garden Salad',
    category: 'Sides',
    unitsSold: 12,
    revenue: 84,
    status: ItemStatus.underperforming,
  ),
  MenuItemReport(
    name: 'Cold Brew',
    category: 'Beverages',
    unitsSold: 85,
    revenue: 425,
    status: ItemStatus.underperforming,
  ),
  MenuItemReport(
    name: 'BBQ Wings',
    category: 'Starters',
    unitsSold: 115,
    revenue: 920,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Margherita Pizza',
    category: 'Mains',
    unitsSold: 95,
    revenue: 1140,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Truffle Pasta',
    category: 'Mains',
    unitsSold: 45,
    revenue: 810,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Caesar Salad',
    category: 'Starters',
    unitsSold: 30,
    revenue: 270,
    status: ItemStatus.underperforming,
  ),
  MenuItemReport(
    name: 'Chocolate Lava Cake',
    category: 'Desserts',
    unitsSold: 88,
    revenue: 616,
    status: ItemStatus.highPerforming,
  ),
  MenuItemReport(
    name: 'Garlic Bread',
    category: 'Sides',
    unitsSold: 150,
    revenue: 600,
    status: ItemStatus.highPerforming,
  ),
];

// ─────────────────────────────────────────────────────────────
// Tab widget
// ─────────────────────────────────────────────────────────────
class MenuAnalysisTab extends StatelessWidget {
  const MenuAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiInsightCard(),
          const SizedBox(height: 24),
          _RankedItemsTable(items: _mockItems),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard();

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
              // Psychology icon circle
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

              // Text content
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
                          const TextSpan(
                            text:
                                'Operational Summary: Your High-Performing Items are dominated by the ',
                          ),
                          TextSpan(
                            text: 'Spicy Zinger Burger',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(
                            text: ', which is currently your top earner ',
                          ),
                          TextSpan(
                            text: '(\$1,200)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const TextSpan(text: '. On the other hand, the '),
                          TextSpan(
                            text: 'Garden Salad',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' is Underperforming—it has very few sales and is not contributing significantly to your revenue.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recommendation block
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
                          Text(
                            'Consider a promotional bundle or a recipe change.',
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
// Ranked Items Table
// ─────────────────────────────────────────────────────────────
class _RankedItemsTable extends StatelessWidget {
  final List<MenuItemReport> items;

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
            // ── Table toolbar ──────────────────────────────────
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
                  // Filter icon button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ── Column headers ─────────────────────────────────
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

            // ── Rows ───────────────────────────────────────────
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return _ItemRow(item: item, isLast: i == items.length - 1);
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
// Single item row
// ─────────────────────────────────────────────────────────────
class _ItemRow extends StatefulWidget {
  final MenuItemReport item;
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
    final isHigh = widget.item.status == ItemStatus.highPerforming;

    // Revenue text: primary color only for top earner
    final isTopEarner = widget.item.revenue == 1200;

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
                  // Item name
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

                  // Category
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

                  // Units sold
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

                  // Revenue
                  Expanded(
                    flex: 18,
                    child: Text(
                      '\$${widget.item.revenue.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isTopEarner ? FontWeight.w800 : FontWeight.w600,
                        color: isTopEarner ? cs.primary : cs.onSurface,
                      ),
                    ),
                  ),

                  // Status badge
                  Expanded(
                    flex: 18,
                    child: Center(child: _StatusBadge(isHigh: isHigh)),
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
// Status badge
// ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isHigh;

  const _StatusBadge({required this.isHigh});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const highColor = Color(0xFF4ade80);
    final lowColor = cs.error;

    final bgColor = isHigh
        ? highColor.withValues(alpha: 0.10)
        : lowColor.withValues(alpha: 0.10);
    final textColor = isHigh ? highColor : lowColor;
    final borderColor = isHigh
        ? highColor.withValues(alpha: 0.20)
        : lowColor.withValues(alpha: 0.20);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
        boxShadow: isHigh
            ? [
                BoxShadow(
                  color: highColor.withValues(alpha: 0.10),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Text(
        isHigh ? 'HIGH PERFORMING' : 'UNDERPERFORMING',
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
