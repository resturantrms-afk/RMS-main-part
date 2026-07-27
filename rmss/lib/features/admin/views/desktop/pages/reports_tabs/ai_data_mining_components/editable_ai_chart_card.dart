import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_bloc.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_event.dart';

class EditableAiChartCard extends StatefulWidget {
  final int index;
  final AiChartData initialChart;
  final VoidCallback? onRemove;

  const EditableAiChartCard({
    super.key,
    required this.index,
    required this.initialChart,
    this.onRemove,
  });

  @override
  State<EditableAiChartCard> createState() => _EditableAiChartCardState();
}

class _EditableAiChartCardState extends State<EditableAiChartCard> {
  late String _title;
  late String _type;
  late Color _primaryColor;
  late dynamic _data;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  bool _isEditingTitle = false;

  final List<Color> _palette = const [
    Color(0xFF5B8FF9),
    Color(0xFFE88328),
    Color(0xFF5AD8A6),
    Color(0xFFBBA598),
    Color(0xFFE96666),
    Color(0xFFA371F7),
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.initialChart.title;
    _type = widget.initialChart.type;
    if (_type != 'pie' &&
        _type != 'donut' &&
        _type != 'bar' &&
        _type != 'line' &&
        _type != 'card' &&
        _type != 'table' &&
        _type != 'text') {
      _type = 'bar'; // Default fallback
    }
    _data = widget.initialChart.data;
    _titleController.text = _title;
    _primaryColor = const Color(0xFF5B8FF9);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_primaryColor == const Color(0xFF5B8FF9)) {
      _primaryColor = Theme.of(context).colorScheme.primary;
    }
  }

  @override
  void didUpdateWidget(EditableAiChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialChart != oldWidget.initialChart) {
      setState(() {
        _title = widget.initialChart.title;
        _type = widget.initialChart.type;
        _data = widget.initialChart.data;
        if (!_isEditingTitle) {
          _titleController.text = _title;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _toggleType(String newType) {
    if (_type == newType) return;

    // Check if both are compatible simple charts
    final simpleCharts = ['bar', 'line', 'pie', 'donut', 'card'];
    if (simpleCharts.contains(_type) && simpleCharts.contains(newType)) {
      setState(() {
        _type = newType;
      });
    } else {
      // Incompatible data, need AI transformation
      context.read<AiBloc>().add(
        TransformChart(index: widget.index, newType: newType),
      );
    }
  }

  void _changeColor(Color color) {
    setState(() {
      _primaryColor = color;
    });
  }

  Widget _buildChart(ColorScheme cs) {
    if (_data == null ||
        (_data is Map && _data.isEmpty) ||
        (_data is List && _data.isEmpty)) {
      return Center(
        child: Text(
          "No data for chart",
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    if (_type == 'text') {
      final String textContent = (_data is String)
          ? _data
          : (_data is Map)
          ? _data.entries.map((e) => '\u2022 ${e.key}: ${e.value}').join('\n\n')
          : _data.toString();

      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textContent.isNotEmpty ? textContent : 'No data to report.',
            style: TextStyle(fontSize: 16, color: cs.onSurface, height: 1.5),
          ),
        ),
      );
    } else if (_type == 'table') {
      if (_data is List) {
        final list = _data as List;
        if (list.isEmpty) return const SizedBox();
        final firstItem = list.first as Map;
        final keys = firstItem.keys.toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: keys
                      .map((k) => DataColumn(label: Text(k.toString())))
                      .toList(),
                  rows: list.map((item) {
                    return DataRow(
                      cells: keys
                          .map(
                            (k) => DataCell(Text((item[k] ?? '').toString())),
                          )
                          .toList(),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      } else if (_data is Map) {
        // Fallback for old map data
        final map = _data as Map;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Category/Item')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: map.entries.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(e.key.toString())),
                        DataCell(Text(e.value.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      }
    }

    // Chart types require a Map
    if (_data is! Map) {
      return Center(
        child: Text(
          "Data format incompatible with this chart type",
          style: TextStyle(color: cs.error),
        ),
      );
    }
    final mapData = _data as Map<String, dynamic>;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_type == 'pie' || _type == 'donut') {
          int idx = 0;
          final double minDim = constraints.maxHeight < constraints.maxWidth
              ? constraints.maxHeight
              : constraints.maxWidth;
          final double radius = _type == 'donut' ? minDim * 0.2 : minDim * 0.4;
          final double centerRadius = _type == 'donut' ? minDim * 0.2 : 0;
          final double fontSize = minDim > 250 ? 16 : 12;

          final sections = mapData.entries.map((e) {
            final val = (e.value is num) ? (e.value as num).toDouble() : 0.0;
            final color = _palette[idx++ % _palette.length];
            return PieChartSectionData(
              value: val,
              title: val.toStringAsFixed(0),
              color: color,
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

          int legendIdx = 0;
          final legendItems = mapData.entries.map((e) {
            final color = _palette[legendIdx++ % _palette.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList();

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: centerRadius,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ),
            ],
          );
        } else if (_type == 'card') {
          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mapData.length > 2 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 120,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: mapData.entries.map((e) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.value.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          final keys = mapData.keys.toList();
          final double axisFontSize = constraints.maxWidth > 400 ? 12 : 10;

          final titlesData = FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();

                  final index = value.toInt();
                  if (index >= 0 && index < keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: 80,
                        child: Text(
                          keys[index],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: axisFontSize,
                            color: cs.onSurfaceVariant,
                            height: 1.2,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          );

          if (_type == 'line') {
            int idx = 0;
            final spots = mapData.entries.map((e) {
              final val = (e.value is num) ? (e.value as num).toDouble() : 0.0;
              return FlSpot((idx++).toDouble(), val);
            }).toList();

            return LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                titlesData: titlesData,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                minX: -0.5,
                maxX: spots.isNotEmpty ? spots.length.toDouble() - 0.5 : 0,
              ),
            );
          } else {
            // bar
            int idx = 0;
            final double computedBarWidth =
                (constraints.maxWidth / (mapData.length * 2.5)).clamp(
                  8.0,
                  48.0,
                );

            final barGroups = mapData.entries.map((e) {
              final val = (e.value is num) ? (e.value as num).toDouble() : 0.0;
              return BarChartGroupData(
                x: idx++,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    color: _primaryColor,
                    width: computedBarWidth,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList();

            return BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: titlesData,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (_type == 'card') {
          width = (constraints.maxWidth - 16) / 2;
          if (width < 300) {
            width = constraints.maxWidth;
          }
        }

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: _type == 'card' ? 340 : 0),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(32),
            ),

            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.onRemove != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onRemove,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                            color: cs.error,
                          ),
                        if (widget.onRemove != null) const SizedBox(width: 8),
                        Expanded(
                          child: _isEditingTitle
                              ? TextField(
                                  controller: _titleController,
                                  focusNode: _titleFocus,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: 'Chart Title',
                                  ),
                                  onSubmitted: (val) {
                                    setState(() {
                                      _title = val.isNotEmpty
                                          ? val
                                          : 'Untitled';
                                      _isEditingTitle = false;
                                    });
                                  },
                                  onTapOutside: (_) {
                                    setState(() {
                                      _title = _titleController.text.isNotEmpty
                                          ? _titleController.text
                                          : 'Untitled';
                                      _isEditingTitle = false;
                                    });
                                  },
                                )
                              : MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingTitle = true;
                                        _titleController.text = _title;
                                      });
                                      _titleFocus.requestFocus();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        // Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_type == 'bar' ||
                                _type == 'line' ||
                                _type == 'card')
                              DropdownButton<Color>(
                                value: _primaryColor,
                                icon: Icon(
                                  Icons.color_lens,
                                  size: 20,
                                  color: cs.onSurfaceVariant,
                                ),
                                underline: const SizedBox(),
                                items:
                                    [
                                          Theme.of(context).colorScheme.primary,
                                          ..._palette,
                                        ]
                                        .toSet() // Ensure unique colors before mapping
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: c,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (c) {
                                  if (c != null) _changeColor(c);
                                },
                              ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButton<String>(
                                value: _type == 'donut' ? 'pie' : _type,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: cs.onSurfaceVariant,
                                ),
                                isDense: true,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'bar',
                                    child: Text(
                                      'Bar Chart',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'line',
                                    child: Text(
                                      'Line Chart',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pie',
                                    child: Text(
                                      'Pie Chart',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'card',
                                    child: Text(
                                      'Stat Cards',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'table',
                                    child: Text(
                                      'Table',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'text',
                                    child: Text(
                                      'Text Report',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) _toggleType(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height:
                          (_type == 'card' ||
                              _type == 'table' ||
                              _type == 'text')
                          ? null
                          : 450,
                      child: _buildChart(cs),
                    ),
                    if (widget.initialChart.explanation.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        widget.initialChart.explanation,
                        style: TextStyle(
                          fontSize: 15,
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.initialChart.isTransforming)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: cs.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Reformatting data...',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
