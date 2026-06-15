import 'package:flutter/material.dart';

class PaymentsHistory extends StatelessWidget {
  const PaymentsHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Center(child: Text('payments history'))],
        ),
      ),
    );
  }
}
