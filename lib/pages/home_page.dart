import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'member_detail_page.dart';

class HomePage extends StatefulWidget {
  final UserModel currentUser;

  const HomePage({
    super.key,
    required this.currentUser,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // =========================================================
  // MEMBERS
  // =========================================================

  List<UserModel> members = [];

  bool isLoading = true;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    loadMembers();
  }

  // =========================================================
  // LOAD MEMBERS FROM API
  // =========================================================

  Future<void> loadMembers() async {

    try {

      final result = await ApiService.getUsers();

      print('HOME USERS RESULT: $result');

      if (!mounted) return;

      if (result['success'] == true) {

        final List users = result['users'] ?? [];

        setState(() {

          members = users.map((user) {

            return UserModel(
              id: user['id'],
              name: user['name'] ?? '',
              username: user['username'] ?? '',
              imagePath: user['image_path'],
            );

          }).toList();

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

      }

    } catch (e) {

      print('LOAD MEMBERS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถโหลดข้อมูลสมาชิกได้',
          ),
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        title: const Text('Home'),
      ),

      // =====================================================
      // DRAWER
      // =====================================================

      drawer: AppDrawer(
        currentUser: widget.currentUser,
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: isLoading

          // =================================================
          // LOADING
          // =================================================

          ? const Center(
              child: CircularProgressIndicator(),
            )

          // =================================================
          // EMPTY
          // =================================================

          : members.isEmpty

              ? RefreshIndicator(
                  onRefresh: loadMembers,

                  child: ListView(
                    children: const [

                      SizedBox(height: 150),

                      Icon(
                        Icons.people_outline,
                        size: 70,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 15),

                      Center(
                        child: Text(
                          'ยังไม่มีสมาชิก',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              // =================================================
              // MEMBER LIST
              // =================================================

              : RefreshIndicator(
                  onRefresh: loadMembers,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),

                    itemCount: members.length,

                    itemBuilder: (context, index) {

                      final member = members[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(12),

                          // =====================================
                          // PROFILE IMAGE
                          // =====================================

                          leading: CircleAvatar(
                            radius: 28,

                            backgroundImage:
                                member.imagePath != null &&
                                        member.imagePath!.isNotEmpty
                                    ? NetworkImage(
                                        member.imagePath!,
                                      )
                                    : null,

                            child:
                                member.imagePath == null ||
                                        member.imagePath!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                      )
                                    : null,
                          ),

                          // =====================================
                          // NAME
                          // =====================================

                          title: Text(
                            member.name,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // =====================================
                          // USERNAME
                          // =====================================

                          subtitle: Text(
                            'Username: ${member.username}',
                          ),

                          // =====================================
                          // ARROW
                          // =====================================

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),

                          // =====================================
                          // CLICK
                          // =====================================

                          onTap: () {

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) =>
                                    MemberDetailPage(
                                  member: member,
                                ),
                              ),
                            );

                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}