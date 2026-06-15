import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';

class CashierDashboardMobile extends StatefulWidget {
  const CashierDashboardMobile({super.key});

  @override
  State<CashierDashboardMobile> createState() => _CashierDashboardMobileState();
}

class _CashierDashboardMobileState extends State<CashierDashboardMobile> {
  int selectedIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Dashboard')),
    Center(child: Text('Menu')),
    Center(child: Text('Orders')),
    Center(child: Text('Payments')),
    Center(child: Text('Setting')),
  ];

  void changeSelectedIndex(int newIndex) {
    if (selectedIndex != newIndex) {
      setState(() {
        selectedIndex = newIndex;
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crown Restaurant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'cashier',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.circle)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        child: ListView(
          children: [
            menuTiles(
              Icons.dashboard,
              'Dashboard',
              () => changeSelectedIndex(0),
              selectedIndex == 0,
            ),
            menuTiles(
              Icons.restaurant_menu,
              'Menu & Pos',
              () => changeSelectedIndex(1),
              selectedIndex == 1,
            ),
            menuTiles(
              Icons.shopping_cart,
              'Orders',
              () => changeSelectedIndex(2),
              selectedIndex == 2,
            ),
            menuTiles(
              Icons.payment,
              'Payments',
              () => changeSelectedIndex(3),
              selectedIndex == 3,
            ),
            menuTiles(
              Icons.settings,
              'Setting',
              () => changeSelectedIndex(4),
              selectedIndex == 4,
            ),

            const Divider(), // A nice little line to separate the menu
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
      ),

      body: _pages[selectedIndex],
    );
  }

  ListTile menuTiles(IconData icon, String text, onTap, bool isSelected) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }
}
