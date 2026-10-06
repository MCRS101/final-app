import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  bool isLoading = false;

  // =========================================================
  // TAKE PHOTO
  // =========================================================

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<void> register() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
        confirmPasswordController.text.trim();

    // ตรวจสอบข้อมูล
    if (name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบ'),
        ),
      );
      return;
    }

    // ตรวจสอบ Password
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password ไม่ตรงกัน'),
        ),
      );
      return;
    }

    // ตรวจสอบรูป
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาถ่ายภาพผู้สมัคร'),
        ),
      );
      return;
    }

    // เริ่ม Loading
    setState(() {
      isLoading = true;
    });

    try {
      // =====================================================
      // ส่งข้อมูลไป API
      // =====================================================

      final result = await ApiService.register(
        name,
        username,
        password,
        selectedImage!,
      );

      print('REGISTER RESULT: $result');

      // =====================================================
      // สมัครสำเร็จ
      // =====================================================

      if (result['success'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สมัครสมาชิกสำเร็จ'),
          ),
        );

        // กลับหน้า Login
        Navigator.pop(context);
      } else {
        // ===================================================
        // สมัครไม่สำเร็จ
        // ===================================================

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'สมัครสมาชิกไม่สำเร็จ',
            ),
          ),
        );
      }
    } catch (e) {
      print('REGISTER ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถเชื่อมต่อ API ได้',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =================================================
            // PHOTO
            // =================================================

            GestureDetector(
              onTap: isLoading ? null : takePhoto,

              child: CircleAvatar(
                radius: 65,

                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : null,

                child: selectedImage == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'แตะเพื่อถ่ายภาพผู้สมัคร',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // NAME
            // =================================================

            TextField(
              controller: nameController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'ชื่อ - นามสกุล',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // USERNAME
            // =================================================

            TextField(
              controller: usernameController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.account_circle),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // PASSWORD
            // =================================================

            TextField(
              controller: passwordController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // CONFIRM PASSWORD
            // =================================================

            TextField(
              controller: confirmPasswordController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'ยืนยัน Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // REGISTER BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isLoading ? null : register,

                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}