import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rmss/features/cashier/views/desktop/pages/home.dart';
import 'package:rmss/features/cashier/views/desktop/pages/menu.dart';
import 'package:rmss/features/cashier/views/desktop/pages/orders.dart';
import 'package:rmss/features/cashier/views/desktop/pages/payments.dart';
import 'package:rmss/features/cashier/views/desktop/pages/settings.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  int selectedIndex = 0;
  bool isExpanded = true;

  final List<Widget> _pages = [
    const Home(),
    const Menu(),
    const Orders(),
    const Payments(),
    const Settings(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                minExtendedWidth: 220,
                minWidth: 65,

                unselectedLabelTextStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),

                unselectedIconTheme: IconThemeData(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),

                selectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
                // waxa loo isticmaalaa marka option la select gareeyo waxa soo baxaya
                indicatorColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
                // obvious
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                // obvious
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    isExpanded
                        ? Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  Icons.restaurant,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Crown Restaurant",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontSize: 17,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Cashier",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 16),
                  ],
                ),

                onDestinationSelected: (index) => setState(() {
                  selectedIndex = index;
                }),
                destinations: [
                  _buildDestination(label: "Dashboard", icon: Icons.dashboard),
                  _buildDestination(
                    label: "Menu & POS",
                    icon: Icons.restaurant_menu,
                  ),
                  _buildDestination(label: "Orders", icon: Icons.shopping_cart),
                  _buildDestination(label: "payments", icon: Icons.payment),
                  _buildDestination(label: "Setting", icon: Icons.settings),
                ],
                selectedIndex: selectedIndex,
                extended: isExpanded,
              ),

              Expanded(child: _pages[selectedIndex]),
            ],
          ),

          // expanding and contracting the navigation rail
          Positioned(
            top: 16,
            left: 12,
            child: IconButton(
              onPressed: () => setState(() {
                isExpanded = !isExpanded;
              }),
              icon: const Icon(Icons.menu),
            ),
          ),

          Positioned(
            bottom: 32,
            left: 20.5,

            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                isExpanded
                    ? Text(
                        "Sign out",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildDestination({
    required String label,
    required IconData icon,
  }) {
    return NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 0.4),
      icon: Icon(icon, size: isExpanded ? 26 : 24),
      label: Text(label),
      selectedIcon: Icon(icon, size: isExpanded ? 26 : 24),
    );
  }
}
