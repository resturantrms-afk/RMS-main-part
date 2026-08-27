import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rmss/core/blocs/app_branding_cubit/app_branding_cubit.dart';

import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_state.dart';

class ReceiptPage extends StatelessWidget {
  final OrderModel order;
  const ReceiptPage({super.key, required this.order});

  Future<void> _generatePdf(BuildContext context) async {
    final branding = context.read<AppBrandingCubit>().state;
    final paymentState = context.read<PaymentBloc>().state;
    final usersState = context.read<AdminUsersBloc>().state;
    
    String operatorName = 'Unknown';
    String operatorLabel = order.status == OrderStatus.paid ? "Processed By" : "Created By";

    if (order.status == OrderStatus.paid && paymentState is PaymentsLoaded) {
      try {
        final payment = paymentState.items.firstWhere((p) => p.orderId == order.id);
        String? processorId = payment.processedBy['user'] ?? payment.processedBy['id'];
        if (processorId != null && usersState is AdminUsersLoaded) {
          try {
            final user = usersState.allUsers.firstWhere((u) => u.id == processorId);
            operatorName = user.name;
          } catch (_) {
            operatorName = payment.processedBy['name'] ?? 'Unknown';
          }
        } else {
          operatorName = payment.processedBy['name'] ?? 'Unknown';
        }
      } catch (_) {
        operatorName = 'Unknown';
      }
    } else {
      if (order.source == OrderSource.web) {
        operatorName = 'Customer';
      } else {
        String? creatorId = order.createdBy['id'] ?? order.createdBy['user'];
        if (creatorId != null && usersState is AdminUsersLoaded) {
          try {
            final user = usersState.allUsers.firstWhere((u) => u.id == creatorId);
            operatorName = user.name;
          } catch (_) {
            operatorName = order.createdBy['name'] ?? 'Unknown';
          }
        } else {
          operatorName = order.createdBy['name'] ?? 'Unknown';
        }
      }
    }
    
    double totalTax = order.totalTax;
    double subtotal = order.totalPrice - totalTax;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Receipt format
        margin: const pw.EdgeInsets.all(16), // Add safe print margin
        build: (pw.Context pwContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  branding.appName,
                  style: const pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Table ${order.tableNumber} - ${order.status == OrderStatus.paid ? "Receipt" : "Invoice"}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Metadata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(order.createdAt.toDate())}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Time: ${DateFormat('hh:mm a').format(order.createdAt.toDate())}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '$operatorLabel: $operatorName',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Order: AH-${order.id.length > 4 ? order.id.substring(0, 4).toUpperCase() : order.id.toUpperCase()}-LX',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'QTY',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'ITEM',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'PRICE',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),

              ...order.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${item.quantity}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            if (item.notes.isNotEmpty)
                              pw.Text(
                                item.notes,
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                  color: PdfColors.grey600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tax:', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    '\$${totalTax.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${order.totalPrice.toStringAsFixed(2)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Thank you for dining with us!',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      final printers = await Printing.listPrinters();
      
      if (printers.isNotEmpty) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Receipt_${order.id}',
        );
      } else {
        final bytes = await pdf.save();
        final dir = Directory.systemTemp;
        final docType = order.status == OrderStatus.paid ? "receipt" : "invoice";
        final file = File('${dir.path}/${docType}_${order.id}.pdf');
        await file.writeAsBytes(bytes);

        if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '', file.path]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [file.path]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [file.path]);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final branding = context.watch<AppBrandingCubit>().state;
    final paymentState = context.watch<PaymentBloc>().state;
    final usersState = context.watch<AdminUsersBloc>().state;
    
    String operatorName = 'Unknown';
    String operatorLabel = order.status == OrderStatus.paid ? "Processed By" : "Created By";

    if (order.status == OrderStatus.paid && paymentState is PaymentsLoaded) {
      try {
        final payment = paymentState.items.firstWhere((p) => p.orderId == order.id);
        String? processorId = payment.processedBy['user'] ?? payment.processedBy['id'];
        if (processorId != null && usersState is AdminUsersLoaded) {
          try {
            final user = usersState.allUsers.firstWhere((u) => u.id == processorId);
            operatorName = user.name;
          } catch (_) {
            operatorName = payment.processedBy['name'] ?? 'Unknown';
          }
        } else {
          operatorName = payment.processedBy['name'] ?? 'Unknown';
        }
      } catch (_) {
        operatorName = 'Unknown';
      }
    } else {
      if (order.source == OrderSource.web) {
        operatorName = 'Customer';
      } else {
        String? creatorId = order.createdBy['id'] ?? order.createdBy['user'];
        if (creatorId != null && usersState is AdminUsersLoaded) {
          try {
            final user = usersState.allUsers.firstWhere((u) => u.id == creatorId);
            operatorName = user.name;
          } catch (_) {
            operatorName = order.createdBy['name'] ?? 'Unknown';
          }
        } else {
          operatorName = order.createdBy['name'] ?? 'Unknown';
        }
      }
    }

    double totalTax = order.totalTax;
    double subtotal = order.totalPrice - totalTax;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.0,
                  colors: [
                    colorScheme.surfaceContainerHigh,
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Section
                            Text(
                              branding.appName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.primary,
                                shadows: [
                                  Shadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 1,
                                  width: 32,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Table ${order.tableNumber} • ${order.status == OrderStatus.paid ? "Receipt" : "Invoice"}"
                                      .toUpperCase(),
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 1,
                                  width: 32,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Metadata Table
                            Container(
                              padding: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildMetaLabel("Date", colorScheme),
                                        _buildMetaValue(
                                          DateFormat(
                                            'MMMM dd, yyyy',
                                          ).format(order.createdAt.toDate()),
                                        ),
                                        const SizedBox(height: 24),
                                        _buildMetaLabel("Time", colorScheme),
                                        _buildMetaValue(
                                          DateFormat(
                                            'hh:mm a',
                                          ).format(order.createdAt.toDate()),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _buildMetaLabel(operatorLabel, colorScheme),
                                        _buildMetaValue(operatorName),
                                        const SizedBox(height: 24),
                                        _buildMetaLabel("Order #", colorScheme),
                                        Text(
                                          "AH-${order.id.length > 4 ? order.id.substring(0, 4).toUpperCase() : order.id.toUpperCase()}-LX",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Items List
                            ...order.items.map(
                              (item) => _buildReceiptItem(item, colorScheme),
                            ),

                            const SizedBox(height: 32),

                            // Calculations Section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "\$${subtotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Tax",
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "\$${totalTax.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    height: 1,
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "TOTAL BALANCE",
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 2,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "\$${order.totalPrice.toStringAsFixed(2)}",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.primary,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: colorScheme.primary,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            order.status == OrderStatus.paid
                                                ? "PAID"
                                                : "PENDING",
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Footer
                            Icon(
                              Icons.restaurant,
                              color: colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "THANK YOU FOR DINING WITH US",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Print PDF Button
                            OutlinedButton.icon(
                              onPressed: () => _generatePdf(context),
                              icon: const Icon(Icons.print, size: 16),
                              label: Text(
                                order.status == OrderStatus.paid ? "PRINT RECEIPT" : "PRINT INVOICE",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                backgroundColor: colorScheme.surfaceContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Decorative elements
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back button to close
          Positioned(
            top: 32,
            left: 32,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: colorScheme.onSurface,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaLabel(String text, ColorScheme colors) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.beVietnamPro(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMetaValue(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReceiptItem(OrderItemModel item, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(color: colors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Text(
              "${item.quantity}x",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                if (item.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "\$${(item.price * item.quantity).toStringAsFixed(2)}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
