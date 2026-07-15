import 'package:flutter/material.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';

// ---------------------------------------------------------------------------
// Enum & data model (mock — not connected to Firestore yet)
// ---------------------------------------------------------------------------
enum _TableStatus { available, occupied, needsCleaning }

class _MockTable {
  final int number;
  final int seats;
  final _TableStatus status;
  final String statusLabel;
  final IconData centerIcon;

  const _MockTable({
    required this.number,
    required this.seats,
    required this.status,
    required this.statusLabel,
    required this.centerIcon,
  });
}

const List<_MockTable> _mockTables = [
  _MockTable(
    number: 1,
    seats: 4,
    status: _TableStatus.available,
    statusLabel: '4 SEATS',
    centerIcon: Icons.table_restaurant,
  ),
  _MockTable(
    number: 2,
    seats: 4,
    status: _TableStatus.occupied,
    statusLabel: '2/4 ACTIVE',
    centerIcon: Icons.person,
  ),
  _MockTable(
    number: 3,
    seats: 6,
    status: _TableStatus.needsCleaning,
    statusLabel: 'PENDING',
    centerIcon: Icons.cleaning_services,
  ),
  _MockTable(
    number: 4,
    seats: 2,
    status: _TableStatus.available,
    statusLabel: '2 SEATS',
    centerIcon: Icons.outdoor_grill,
  ),
  _MockTable(
    number: 5,
    seats: 4,
    status: _TableStatus.occupied,
    statusLabel: 'BILLING',
    centerIcon: Icons.restaurant,
  ),
  _MockTable(
    number: 6,
    seats: 8,
    status: _TableStatus.available,
    statusLabel: '8 SEATS',
    centerIcon: Icons.king_bed,
  ),
];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int available = _mockTables
        .where((t) => t.status == _TableStatus.available)
        .length;
    final int occupied = _mockTables
        .where((t) => t.status == _TableStatus.occupied)
        .length;
    final int needsCleaning = _mockTables
        .where((t) => t.status == _TableStatus.needsCleaning)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            const AdminTopBar(),
            const SizedBox(height: 24),

            // ── Header row ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Breadcrumb + title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tables',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Management',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        children: [
                          const TextSpan(text: 'Dining Hall '),
                          TextSpan(
                            text: 'Layout',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Create button
                _CreateTableButton(),
              ],
            ),

            const SizedBox(height: 32),

            // ── Stat cards ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Available Now',
                    value: '$available',
                    suffix: '/ ${_mockTables.length}',
                    accentColor: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Occupied',
                    value: '$occupied',
                    accentColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Needs Cleaning',
                    value: '$needsCleaning',
                    accentColor: colorScheme.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Table grid ─────────────────────────────────────────────────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 1100
                      ? 4
                      : constraints.maxWidth > 760
                      ? 3
                      : 2;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _mockTables.length,
                    itemBuilder: (context, index) =>
                        _TableCard(table: _mockTables[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create Table Button
// ---------------------------------------------------------------------------
class _CreateTableButton extends StatefulWidget {
  @override
  State<_CreateTableButton> createState() => _CreateTableButtonState();
}

class _CreateTableButtonState extends State<_CreateTableButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle, color: colorScheme.onPrimary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'CREATE NEW TABLE',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final Color accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 6),
                Text(
                  suffix!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Table card
// ---------------------------------------------------------------------------
class _TableCard extends StatefulWidget {
  final _MockTable table;
  const _TableCard({required this.table});

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _iconAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _iconAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _iconAnim, curve: Curves.easeOutBack));
    _rotateAnim = Tween<double>(
      begin: 0.0,
      end: 0.08,
    ).animate(CurvedAnimation(parent: _iconAnim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _iconAnim.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _hovered = true);
    _iconAnim.forward();
  }

  void _onExit(_) {
    setState(() => _hovered = false);
    _iconAnim.reverse();
  }

  // ── Status helpers ───────────────────────────────────────────────────────
  Color _statusBg(ColorScheme cs) => switch (widget.table.status) {
    _TableStatus.available => const Color(0xFF4CAF50).withValues(alpha: 0.12),
    _TableStatus.occupied => cs.primary.withValues(alpha: 0.12),
    _TableStatus.needsCleaning => cs.primary.withValues(alpha: 0.12),
  };

  Color _statusFg(ColorScheme cs) => switch (widget.table.status) {
    _TableStatus.available => const Color(0xFF4CAF50),
    _TableStatus.occupied => cs.primary,
    _TableStatus.needsCleaning => cs.primary,
  };

  String _statusText() => switch (widget.table.status) {
    _TableStatus.available => 'Available',
    _TableStatus.occupied => 'Occupied',
    _TableStatus.needsCleaning => 'Needs Cleaning',
  };

  Color _iconColor(ColorScheme cs) => switch (widget.table.status) {
    _TableStatus.available => cs.onSurfaceVariant.withValues(alpha: 0.35),
    _TableStatus.occupied => cs.primary.withValues(alpha: 0.65),
    _TableStatus.needsCleaning => cs.primary.withValues(alpha: 0.65),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? colorScheme.primary.withValues(alpha: 0.25)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: _hovered ? 24 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${widget.table.number}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(colorScheme),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _statusFg(colorScheme).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _statusText().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: _statusFg(colorScheme),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Icon box ─────────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _iconAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnim.value,
                              child: Transform.rotate(
                                angle: _rotateAnim.value,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            widget.table.centerIcon,
                            size: 48,
                            color: _iconColor(colorScheme),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.table.statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: _iconColor(colorScheme),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── QR button ────────────────────────────────────────────────
              _QrButton(hovered: _hovered),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR button with its own hover state
// ---------------------------------------------------------------------------
class _QrButton extends StatefulWidget {
  final bool cardHovered;
  const _QrButton({required bool hovered}) : cardHovered = hovered;

  @override
  State<_QrButton> createState() => _QrButtonState();
}

class _QrButtonState extends State<_QrButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 18,
                color: active ? colorScheme.onPrimary : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Generate QR Code',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
