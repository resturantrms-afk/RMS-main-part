import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_bloc.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_event.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_state.dart';
import 'dart:math';

class AiDataMiningTab extends StatefulWidget {
  const AiDataMiningTab({super.key});

  @override
  State<AiDataMiningTab> createState() => _AiDataMiningTabState();
}

class _AiDataMiningTabState extends State<AiDataMiningTab> {
  final TextEditingController _chatController = TextEditingController();
  double _aiWidth = 350.0;
  bool _isChatVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiBloc(),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel: Dashboard
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isChatVisible) const SizedBox(height: 64),
                      _buildLeftPanel(context),
                    ],
                  ),
                ),
              ),
              if (_isChatVisible) ...[
                // Resizable Handle
                MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _aiWidth = (_aiWidth - details.delta.dx).clamp(300.0, 800.0);
                      });
                    },
                    child: Container(
                      width: 24,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Container(
                        height: 64,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right Panel: AI Chat
                SizedBox(
                  width: _aiWidth,
                  child: _buildRightPanel(context),
                ),
              ],
            ],
          ),
          if (!_isChatVisible)
            Positioned(
              right: 0,
              top: 0,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isChatVisible = true),
                icon: const Icon(Icons.smart_toy),
                label: const Text('AI Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // First Part: Main Chart Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predicted Revenue (Next 30 Days)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'May 2 - June 1, 2026',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Mock Chart Area
              SizedBox(
                height: 250,
                child: CustomPaint(
                  size: const Size(double.infinity, 250),
                  painter: _MockChartPainter(cs),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48), // Increased space to separate the two parts
        // Second Part: Recommendation Cards
        Row(
          children: [
            Expanded(
              child: _buildRecommendationCard(
                context: context,
                icon: Icons.local_dining,
                title: 'Predicted Top-Selling Item',
                mainValue: 'Truffle Mac & Cheese',
                subValue: '450',
                subValueLabel: 'units',
                highlightColor: const Color(0xFF00E5FF),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildStaffingCard(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String mainValue,
    required String subValue,
    required String subValueLabel,
    required Color highlightColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: highlightColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                subValue,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: highlightColor,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  subValueLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffingCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups, color: cs.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            'Staffing Recommendation',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Increase FOH staff by 2 on Fri/Sat Dinner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStaffingDayBadge(context, 'FRI', '+2', cs.primary),
              const SizedBox(width: 8),
              _buildStaffingDayBadge(context, 'SAT', '+2', cs.primary),
              const SizedBox(width: 8),
              _buildStaffingDayBadge(context, 'SUN', 'Normal', cs.onSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffingDayBadge(BuildContext context, String day, String value, Color valueColor) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chat with AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _isChatVisible = false;
                    });
                  },
                  tooltip: 'Hide Chat',
                ),
              ],
            ),
          ),
          // Chat History
          Expanded(
            child: BlocBuilder<AiBloc, AiState>(
              builder: (context, state) {
                if (state is AiGenerating) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AiReportReady) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Mock user message
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16, left: 32),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            state.canvasData.originalQuery,
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                      ),
                      // AI response
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16, right: 32),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.canvasData.textReport ?? "Here is the analysis based on your data.",
                                style: TextStyle(color: cs.onSurface, height: 1.5),
                              ),
                              if (state.canvasData.textReport == null || state.canvasData.textReport!.isEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  "• Traffic peaks at 8 PM.",
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                Text(
                                  "• Top items: Truffle Mac & Cheese, Dry-Aged Ribeye.",
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                Text(
                                  "• Sales for Cocktails are up 15%.",
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.lightbulb, size: 16, color: Color(0xFF00E5FF)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'RECOMMENDATION',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF00E5FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Consider increasing FOH staff by 2 during the 7 PM - 9 PM rush.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is AiError) {
                  return Center(
                    child: Text('Error: ${state.message}', style: TextStyle(color: cs.error)),
                  );
                } else {
                  return Center(
                    child: Text(
                      'Ask a question to start data mining',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }
              },
            ),
          ),
          // Input Area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickPrompt(context, 'Analyze Friday night trends'),
                    _buildQuickPrompt(context, 'Predict next weekend volume'),
                    _buildQuickPrompt(context, 'Compare this month vs last'),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (blocContext) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: "Ask me to mine your data...",
                              filled: true,
                              fillColor: cs.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                blocContext.read<AiBloc>().add(GenerateAiReport(
                                  query: value,
                                  preferredLevel: AiLevel.basic,
                                ));
                                _chatController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              if (_chatController.text.isNotEmpty) {
                                blocContext.read<AiBloc>().add(GenerateAiReport(
                                  query: _chatController.text,
                                  preferredLevel: AiLevel.basic,
                                ));
                                _chatController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        _chatController.text = text;
      },
      borderRadius: BorderRadius.circular(24),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MockChartPainter extends CustomPainter {
  final ColorScheme cs;

  _MockChartPainter(this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final paintGrid = Paint()
      ..color = cs.outline.withOpacity(0.1)
      ..strokeWidth = 1;
      
    // Draw horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = h * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(w, y), paintGrid);
    }
    
    // Gradient line setup
    final List<Offset> points = [
      Offset(0, h * 0.8),
      Offset(w * 0.3, h * 0.6),
      Offset(w * 0.7, h * 0.4),
      Offset(w, h * 0.2),
    ];
    
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      // Simple cubic bezier curve approximation for smoothness
      final prev = points[i - 1];
      final curr = points[i];
      final controlX = (prev.dx + curr.dx) / 2;
      path.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
    }
    
    // Create gradient
    final gradient = LinearGradient(
      colors: [cs.primary, const Color(0xFF00E5FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    
    // Draw area under curve
    final areaPath = Path.from(path);
    areaPath.lineTo(w, h);
    areaPath.lineTo(0, h);
    areaPath.close();
    
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.2),
          const Color(0xFF00E5FF).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
      
    canvas.drawPath(areaPath, areaPaint);

    // Draw line
    final paintLine = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    canvas.drawPath(path, paintLine);
    
    // Draw dots
    final paintDotOuter = Paint()..style = PaintingStyle.fill;
    final paintDotInner = Paint()
      ..color = cs.surfaceContainerLowest
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      paintDotOuter.color = i < points.length / 2 ? cs.primary : const Color(0xFF00E5FF);
      canvas.drawCircle(points[i], 6, paintDotOuter);
      canvas.drawCircle(points[i], 3, paintDotInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
