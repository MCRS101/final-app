
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/camera_page.dart';
import '../pages/household/houseListPage.dart';
import '../pages/map/householdMapPage.dart';

class AppDrawer extends StatelessWidget {
  final UserModel currentUser;

  const AppDrawer({
    super.key,
    required this.currentUser,
  });

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),

            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,

              backgroundImage: 
                  currentUser.imagePath != null &&
                        currentUser.imagePath!.isNotEmpty
                    ? NetworkImage(
                        currentUser.imagePath!,
                      )
                      : null,

              child:
                currentUser.imagePath == null ||
                        currentUser.imagePath!.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null,
            ),

            accountName: Text(
              currentUser.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            accountEmail: Text(
              '@${currentUser.username}',
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),

            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomePage(
                    currentUser: currentUser,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),

            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraPage(),
                  ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Household'),

            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HouseListPage(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Household Map'),

            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HouseholdMapPage(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),

            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
              ),
            ),

            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}

