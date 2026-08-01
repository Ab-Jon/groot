import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'explore_screen.dart';

class HumanitarianDashboard extends StatefulWidget {
  const HumanitarianDashboard({super.key});

  @override
  State<HumanitarianDashboard> createState() => _HumanitarianDashboardState();
}

class _HumanitarianDashboardState extends State<HumanitarianDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle home tab here
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.explore),
                title: Text('Explore Needs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ExploreScreen()));
                  // Handle explore needs tab here
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem),
                title: Text('High Demand Alerts'),
                onTap: () {
                  // Handle high demand alerts tab here
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.insights),
                title: Text('Location Insights'),
                onTap: () {
                  // Handle location insights tab here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(Icons.menu))
          ),
          title: Text('Humanitarian Dashboard'),
          elevation: 10.0,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.person)),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              DashboardCard(
                  title: 'Total Needs', value: '1,713', color: Colors.green),
              DashboardCard(
                  title: 'Pending Review', value: '286', color: Colors.orange),
              DashboardCard(
                  title: 'Verified', value: '1020', color: Colors.teal),
              DashboardCard(
                  title: 'Resolved', value: '874', color: Colors.purple),
            ],
          ),
        ));
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFFF9F4FF), // very light purple background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
