import 'package:flutter/material.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/orders_report_tab.dart';

class CashierReportsPage extends StatefulWidget {
  const CashierReportsPage({super.key});

  @override
  State<CashierReportsPage> createState() => _CashierReportsPageState();
}

class _CashierReportsPageState extends State<CashierReportsPage> {
  final GlobalKey _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REPORTS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: OrdersReportTab(exportKey: _exportKey),
            ),
          ],
        ),
      ),
    );
  }
}
