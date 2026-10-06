import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  // =========================================================
  // เปิดกล้อง
  // =========================================================

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // =========================================================
  // บันทึกลง Gallery
  // =========================================================

  Future<void> saveToGallery() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาถ่ายภาพก่อน'),
        ),
      );

      return;
    }

    try {
      final result =
          await ImageGallerySaverPlus.saveFile(
        selectedImage!.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result != null
                ? 'บันทึกรูปลง Gallery แล้ว'
                : 'ไม่สามารถบันทึกรูปได้',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เกิดข้อผิดพลาด: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // ถ่ายรูปใหม่
  // =========================================================

  void deletePhoto() {
    setState(() {
      selectedImage = null;
    });
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =================================================
            // รูปภาพ
            // =================================================

            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),

                child: selectedImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 15),

                            Text(
                              'ยังไม่มีรูปภาพ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'กดปุ่มด้านล่างเพื่อถ่ายภาพ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(16),

                        child: Image.file(
                          selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // ปุ่ม
            // =================================================

            if (selectedImage == null)
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: takePhoto,

                  icon: const Icon(
                    Icons.camera_alt,
                  ),

                  label: const Text(
                    'ถ่ายภาพ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton.icon(
                      onPressed: saveToGallery,

                      icon: const Icon(
                        Icons.save_alt,
                      ),

                      label: const Text(
                        'บันทึกลง Gallery',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: OutlinedButton.icon(
                      onPressed: deletePhoto,

                      icon: const Icon(
                        Icons.camera_alt,
                      ),

                      label: const Text(
                        'ถ่ายภาพใหม่',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

