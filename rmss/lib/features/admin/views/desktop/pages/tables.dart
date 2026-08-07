import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  TableStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        List<TableModel> tables = [];
        if (state is TablesLoaded) {
          tables = List<TableModel>.from(state.items)
            ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
        }

        final int available = tables
            .where((t) => t.status == TableStatus.available)
            .length;
        final int occupied = tables
            .where((t) => t.status == TableStatus.occupied)
            .length;
        final int needsCleaning = tables
            .where((t) => t.status == TableStatus.needsCleaning)
            .length;

        final displayedTables = _selectedFilter == null
            ? tables
            : tables.where((t) => t.status == _selectedFilter).toList();

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '/',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.3),
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

                    // Download all QRs
                    _DownloadAllQrCodesButton(tables: tables),
                    const SizedBox(width: 16),

                    // Create button
                    _CreateTableButton(),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Stat cards ─────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter =
                                  _selectedFilter == TableStatus.available
                                  ? null
                                  : TableStatus.available;
                            });
                          },
                          child: _StatCard(
                            label: 'Available Now',
                            value: '$available',
                            suffix: '/ ${tables.length}',
                            accentColor: const Color(0xFF4CAF50),
                            isSelected:
                                _selectedFilter == TableStatus.available,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter =
                                  _selectedFilter == TableStatus.occupied
                                  ? null
                                  : TableStatus.occupied;
                            });
                          },
                          child: _StatCard(
                            label: 'Occupied',
                            value: '$occupied',
                            accentColor: colorScheme.primary,
                            isSelected: _selectedFilter == TableStatus.occupied,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter =
                                  _selectedFilter == TableStatus.needsCleaning
                                  ? null
                                  : TableStatus.needsCleaning;
                            });
                          },
                          child: _StatCard(
                            label: 'Needs Cleaning',
                            value: '$needsCleaning',
                            accentColor: colorScheme.primary.withValues(
                              alpha: 0.55,
                            ),
                            isSelected:
                                _selectedFilter == TableStatus.needsCleaning,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Active Filter Text ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFilter == null
                            ? Icons.table_restaurant
                            : Icons.filter_list,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedFilter == null
                            ? 'Showing all ${tables.length} tables'
                            : 'Showing ${displayedTables.length} ${_selectedFilter == TableStatus.available
                                  ? 'available'
                                  : _selectedFilter == TableStatus.occupied
                                  ? 'occupied'
                                  : 'needs cleaning'} tables',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

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
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: displayedTables.length,
                        itemBuilder: (context, index) =>
                            _TableCard(table: displayedTables[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Download All QR Codes Button
// ---------------------------------------------------------------------------
class _DownloadAllQrCodesButton extends StatefulWidget {
  final List<TableModel> tables;
  const _DownloadAllQrCodesButton({required this.tables});

  @override
  State<_DownloadAllQrCodesButton> createState() =>
      _DownloadAllQrCodesButtonState();
}

class _DownloadAllQrCodesButtonState extends State<_DownloadAllQrCodesButton> {
  bool _hovered = false;
  bool _isDownloading = false;

  Future<void> _downloadAll() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrColor = isDark ? colorScheme.surface : colorScheme.onSurface;
    final qrBgColor = isDark ? colorScheme.onSurface : colorScheme.surface;

    setState(() => _isDownloading = true);
    final baseUrl =
        dotenv.env['CUSTOMER_SITE_URL'] ?? 'https://testproject-9d7aa.web.app';

    final archive = Archive();

    for (final table in widget.tables) {
      final url = '$baseUrl/?table=${table.tableNumber}';
      final painter = QrPainter(
        data: url,
        version: QrVersions.auto,
        gapless: true,
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: qrColor,
        ),
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: qrColor),
      );

      final picRecorder = ui.PictureRecorder();
      final canvas = ui.Canvas(picRecorder);
      const size = ui.Size(2048, 2048);
      final bgPaint = ui.Paint()..color = qrBgColor;
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
      painter.paint(canvas, size);
      final picture = picRecorder.endRecording();
      final image = await picture.toImage(2048, 2048);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final formattedNum = table.tableNumber.toString().padLeft(3, '0');
        final filename = 'QR_Codes/Table_${formattedNum}_QR.png';
        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive);

    await FileSaver.instance.saveFile(
      name: 'Table_QR_Codes',
      bytes: Uint8List.fromList(zipBytes),
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );

    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All QR Codes downloaded!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: _isDownloading ? null : _downloadAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDownloading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(Icons.download, color: colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isDownloading ? 'DOWNLOADING...' : 'DOWNLOAD ALL QR CODES',
                  style: TextStyle(
                    color: colorScheme.primary,
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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<TableBloc>(),
              child: const _AddTableDialog(),
            ),
          ),
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
// Add Table Dialog
// ---------------------------------------------------------------------------
class _AddTableDialog extends StatefulWidget {
  const _AddTableDialog();

  @override
  State<_AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<_AddTableDialog> {
  final _tableNumberCtrl = TextEditingController();
  TableStatus _status = TableStatus.available;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tableNumberCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tableNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.18),
                      colorScheme.primary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.table_restaurant,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Table',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Enter a table number to create it.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Form body
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table Number',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _tableNumberCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 12',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.numbers,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Initial Status',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TableStatus>(
                          value: _status,
                          isExpanded: true,
                          dropdownColor: colorScheme.surfaceContainer,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: colorScheme.primary,
                          ),
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                          items: TableStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s.name[0].toUpperCase() +
                                        s.name.substring(1),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isLoading || _tableNumberCtrl.text.trim().isEmpty
                          ? null
                          : () {
                              final numText = _tableNumberCtrl.text.trim();
                              final tableNum = int.tryParse(numText);
                              if (tableNum == null || tableNum <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid table number.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final tableState = context.read<TableBloc>().state;
                              if (tableState is TablesLoaded) {
                                final bool exists = tableState.items.any((t) => t.tableNumber == tableNum);
                                if (exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Table $tableNum already exists.'),
                                      backgroundColor: colorScheme.error,
                                    ),
                                  );
                                  return;
                                }
                              }
                              setState(() => _isLoading = true);
                              final newTable = TableModel(
                                id: '',
                                tableNumber: tableNum,
                                status: _status,
                              );
                              context.read<TableBloc>().add(
                                AddTable(item: newTable),
                              );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Table $tableNum created successfully.',
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add, size: 18),
                      label: const Text(
                        'CREATE TABLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
  final bool isSelected;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    this.suffix,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: accentColor, width: 2)
            : Border(left: BorderSide(color: accentColor, width: 4)),
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
        mainAxisSize: MainAxisSize.min,
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
  final TableModel table;
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
  Color _statusBg(ColorScheme cs) {
    if (widget.table.needsHelp)
      return const Color(0xFFF44336).withValues(alpha: 0.12);
    return switch (widget.table.status) {
      TableStatus.available => const Color(0xFF4CAF50).withValues(alpha: 0.12),
      TableStatus.occupied => cs.primary.withValues(alpha: 0.12),
      TableStatus.needsCleaning => cs.primary.withValues(alpha: 0.12),
    };
  }

  Color _statusFg(ColorScheme cs) {
    if (widget.table.needsHelp) return const Color(0xFFF44336);
    return switch (widget.table.status) {
      TableStatus.available => const Color(0xFF4CAF50),
      TableStatus.occupied => cs.primary,
      TableStatus.needsCleaning => cs.primary,
    };
  }

  String _statusText() {
    if (widget.table.needsHelp) return 'Needs Help';
    return switch (widget.table.status) {
      TableStatus.available => 'Available',
      TableStatus.occupied => 'Occupied',
      TableStatus.needsCleaning => 'Needs Cleaning',
    };
  }

  Color _iconColor(ColorScheme cs) {
    if (widget.table.needsHelp)
      return const Color(0xFFF44336).withValues(alpha: 0.65);
    return switch (widget.table.status) {
      TableStatus.available => cs.onSurfaceVariant.withValues(alpha: 0.35),
      TableStatus.occupied => cs.primary.withValues(alpha: 0.65),
      TableStatus.needsCleaning => cs.primary.withValues(alpha: 0.65),
    };
  }

  String _statusLabel() {
    if (widget.table.needsHelp) return 'HELP';
    return switch (widget.table.status) {
      TableStatus.available => 'AVAILABLE',
      TableStatus.occupied => 'OCCUPIED',
      TableStatus.needsCleaning => 'PENDING',
    };
  }

  IconData _centerIcon() {
    if (widget.table.needsHelp) return Icons.help_outline;
    return switch (widget.table.status) {
      TableStatus.available => Icons.table_restaurant,
      TableStatus.occupied => Icons.person,
      TableStatus.needsCleaning => Icons.cleaning_services,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${widget.table.tableNumber}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                            _centerIcon(),
                            size: 48,
                            color: _iconColor(colorScheme),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusLabel(),
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

              // ── Bottom action row: Delete + Change Status + QR ──────────
              Row(
                children: [
                  // Delete button
                  _DeleteTableButton(table: widget.table),
                  const SizedBox(width: 8),
                  // Change status button
                  _ChangeStatusButton(table: widget.table),
                  const SizedBox(width: 8),
                  // QR button
                  Expanded(
                    child: _QrButton(
                      hovered: _hovered,
                      tableNumber: widget.table.tableNumber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change Status Button
// ---------------------------------------------------------------------------
class _ChangeStatusButton extends StatefulWidget {
  final TableModel table;
  const _ChangeStatusButton({required this.table});

  @override
  State<_ChangeStatusButton> createState() => _ChangeStatusButtonState();
}

class _ChangeStatusButtonState extends State<_ChangeStatusButton> {
  bool _hovered = false;

  // Per-status colours
  Color _statusColor(TableStatus s, ColorScheme cs) => switch (s) {
    TableStatus.available => const Color(0xFF4CAF50),
    TableStatus.occupied => cs.primary,
    TableStatus.needsCleaning => const Color(0xFFF59E0B),
  };

  IconData _statusIcon(TableStatus s) => switch (s) {
    TableStatus.available => Icons.check_circle_outline,
    TableStatus.occupied => Icons.person,
    TableStatus.needsCleaning => Icons.cleaning_services_outlined,
  };

  String _statusLabel(TableStatus s) => switch (s) {
    TableStatus.available => 'Available',
    TableStatus.occupied => 'Occupied',
    TableStatus.needsCleaning => 'Needs Cleaning',
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _showStatusPicker(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.swap_horiz_rounded,
            size: 18,
            color: _hovered
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext ctx) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final bloc = ctx.read<TableBloc>();
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.14),
                        colorScheme.primary.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Table ${widget.table.tableNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status options
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: TableStatus.values.map((status) {
                      final isCurrentStatus = widget.table.status == status;
                      final color = _statusColor(status, colorScheme);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MouseRegion(
                          cursor: isCurrentStatus
                              ? SystemMouseCursors.basic
                              : SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: isCurrentStatus
                                ? null
                                : () {
                                    showDialog(
                                      context: ctx,
                                      builder: (confirmCtx) => AlertDialog(
                                        title: const Text(
                                          'Change Status & Cancel Orders?',
                                        ),
                                        content: Text(
                                          'Changing the status of Table ${widget.table.tableNumber} to ${_statusLabel(status)} will automatically cancel all active orders for this table.\n\nAre you sure you want to proceed?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(confirmCtx).pop(),
                                            child: const Text('CANCEL'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final updated = TableModel(
                                                id: widget.table.id,
                                                tableNumber:
                                                    widget.table.tableNumber,
                                                status: status,
                                              );
                                              bloc.add(
                                                UpdateTable(item: updated),
                                              );

                                              // Cancel active orders
                                              final orderBloc = ctx
                                                  .read<OrderBloc>();
                                              if (orderBloc.state
                                                  is OrderLoaded) {
                                                final orders =
                                                    (orderBloc.state
                                                            as OrderLoaded)
                                                        .items;
                                                final activeOrders = orders
                                                    .where(
                                                      (o) =>
                                                          o.tableNumber ==
                                                              widget
                                                                  .table
                                                                  .tableNumber &&
                                                          o.status !=
                                                              OrderStatus
                                                                  .cancelled &&
                                                          o.status !=
                                                              OrderStatus.paid,
                                                    );

                                                for (var order
                                                    in activeOrders) {
                                                  final cancelledOrder = order
                                                      .copyWith(
                                                        status: OrderStatus
                                                            .cancelled,
                                                      );
                                                  orderBloc.add(
                                                    UpdateOrder(
                                                      item: cancelledOrder,
                                                    ),
                                                  );
                                                }
                                              }

                                              Navigator.of(
                                                confirmCtx,
                                              ).pop(); // Close confirm dialog
                                              Navigator.of(
                                                dialogCtx,
                                              ).pop(); // Close status picker dialog
                                              ScaffoldMessenger.of(
                                                ctx,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Table ${widget.table.tableNumber} updated & active orders cancelled.',
                                                  ),
                                                  backgroundColor:
                                                      colorScheme.primary,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Text('PROCEED'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentStatus
                                    ? color.withValues(alpha: 0.12)
                                    : colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrentStatus
                                      ? color.withValues(alpha: 0.45)
                                      : colorScheme.outlineVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                  width: isCurrentStatus ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _statusIcon(status),
                                      size: 16,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _statusLabel(status),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrentStatus
                                            ? color
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentStatus)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'CURRENT',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: color,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
// Delete Table Button
// ---------------------------------------------------------------------------
class _DeleteTableButton extends StatefulWidget {
  final TableModel table;
  const _DeleteTableButton({required this.table});

  @override
  State<_DeleteTableButton> createState() => _DeleteTableButtonState();
}

class _DeleteTableButtonState extends State<_DeleteTableButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Builder(
                  builder: (ctx) {
                    final cs = Theme.of(ctx).colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cs.error.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: cs.error,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Delete Table',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Are you sure you want to delete Table ${widget.table.tableNumber}? This action cannot be undone.',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.onSurfaceVariant,
                                  side: BorderSide(color: cs.outlineVariant),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: cs.error,
                                  foregroundColor: cs.onError,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'DELETE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          if (confirm == true && context.mounted) {
            context.read<TableBloc>().add(DeleteTable(item: widget.table));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered
                ? colorScheme.error.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline,
            size: 18,
            color: _hovered ? colorScheme.error : colorScheme.onSurfaceVariant,
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
  final int tableNumber;
  const _QrButton({required bool hovered, required this.tableNumber})
    : cardHovered = hovered;

  @override
  State<_QrButton> createState() => _QrButtonState();
}

class _QrButtonState extends State<_QrButton> {
  bool _hovered = false;

  void _showQrDialog(BuildContext context, int tableNumber) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrColor = isDark ? colorScheme.surface : colorScheme.onSurface;
    final qrBgColor = isDark ? colorScheme.onSurface : colorScheme.surface;

    final baseUrl =
        dotenv.env['CUSTOMER_SITE_URL'] ?? 'https://testproject-9d7aa.web.app';
    final url = '$baseUrl/#/?table=$tableNumber';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Table $tableNumber QR Code'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 150.0,
                backgroundColor: qrBgColor,
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: qrColor,
                ),
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: qrColor,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
              ),
              onPressed: () async {
                final painter = QrPainter(
                  data: url,
                  version: QrVersions.auto,
                  gapless: true,
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: qrColor,
                  ),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: qrColor,
                  ),
                );

                final picRecorder = ui.PictureRecorder();
                final canvas = ui.Canvas(picRecorder);
                const size = ui.Size(2048, 2048);
                final bgPaint = ui.Paint()..color = qrBgColor;
                canvas.drawRect(
                  ui.Rect.fromLTWH(0, 0, size.width, size.height),
                  bgPaint,
                );
                painter.paint(canvas, size);
                final picture = picRecorder.endRecording();
                final image = await picture.toImage(2048, 2048);
                final byteData = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );

                if (byteData == null) return;

                final bytes = byteData.buffer.asUint8List();
                await FileSaver.instance.saveFile(
                  name: 'Table_${tableNumber}_QR',
                  bytes: bytes,
                  fileExtension: 'png',
                  mimeType: MimeType.png,
                );
              },
              child: const Text('Download Image'),
            ),
            TextButton(
              style: ButtonStyle(
                mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          _showQrDialog(context, widget.tableNumber);
        },
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
