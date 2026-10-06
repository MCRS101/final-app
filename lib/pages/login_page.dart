
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import 'home_page.dart';
import 'register_page.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

// =========================================================
  // LOGIN
  // =========================================================

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // ตรวจสอบช่องว่าง
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอก Username และ Password'),
        ),
      );
      return;
    }

    // เริ่ม Loading
    setState(() {
      isLoading = true;
    });

    try {
      // เรียก API
      final result = await ApiService.login(
        username,
        password,
      );

      print('LOGIN RESULT: $result');

      // Login สำเร็จ
      if (result['success'] == true) {
        final userData = result['user'];

        // แปลงข้อมูลจาก API เป็น UserModel
        final user = UserModel(
          id: userData['id'],
          name: userData['name'],
          username: userData['username'],
          imagePath: userData['image_path'],
        );

        if (!mounted) return;

        // ไปหน้า Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              currentUser: user,
            ),
          ),
        );
      } else {
        // Login ไม่สำเร็จ
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Username หรือ Password ไม่ถูกต้อง',
            ),
          ),
        );
      }
    } catch (e) {
      print('LOGIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถเชื่อมต่อ Server ได้',
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.home_work,
                  size: 90,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Household App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'ระบบจัดการข้อมูลสมาชิกและครัวเรือน',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,

                    child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ยังไม่มีบัญชี?'),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('สมัครสมาชิก'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Demo Login: admin / 1234',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

