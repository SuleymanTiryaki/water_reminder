import 'package:flutter/material.dart';

import 'package:waterreminder/product/water_reminder/view/hydration_pool_page.dart';
import 'package:waterreminder/product/water_reminder/view/hydration_progress_page.dart';
import 'package:waterreminder/product/water_reminder/view/settings_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.pool, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text("Havuz", style: TextStyle(color: Theme.of(context).primaryColor)),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                  ),
                  body: HydrationPoolPage(),
                )),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text("Ayarlar", style: TextStyle(color: Theme.of(context).primaryColor)),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                  ),
                  body: SettingsPage(),
                )),
              );
            },
          ),
        ],
      ),
      body: HydrationProgressPage(),
    );
  }
}
