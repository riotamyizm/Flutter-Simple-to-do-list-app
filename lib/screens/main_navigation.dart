import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = [
    HomeScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDesktop(context)
          ? Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.list), label: Text('Task')),
              NavigationRailDestination(
                  icon: Icon(Icons.bar_chart), label: Text('Statistik')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[index]),
        ],
      )
          : pages[index],
      bottomNavigationBar: isDesktop(context)
          ? null
          : BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Task'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
