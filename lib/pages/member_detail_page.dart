import 'package:flutter/material.dart';

import '../models/user_model.dart';

class MemberDetailPage extends StatelessWidget {

  final UserModel member;

  const MemberDetailPage({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        title: const Text('รายละเอียดสมาชิก'),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // =================================================
            // PROFILE IMAGE
            // =================================================

            CircleAvatar(
              radius: 60,

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
                          size: 60,
                        )
                      : null,
            ),

            const SizedBox(height: 25),

            // =================================================
            // NAME
            // =================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [

                    ListTile(
                      leading: const Icon(
                        Icons.person,
                      ),

                      title: const Text(
                        'ชื่อ',
                      ),

                      subtitle: Text(
                        member.name,
                      ),
                    ),

                    const Divider(),

                    // =========================================
                    // USERNAME
                    // =========================================

                    ListTile(
                      leading: const Icon(
                        Icons.account_circle,
                      ),

                      title: const Text(
                        'Username',
                      ),

                      subtitle: Text(
                        member.username,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}