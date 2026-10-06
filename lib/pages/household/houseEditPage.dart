import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/house_model.dart';
import '../../services/api_service.dart';
import 'selectLocationPage.dart';

class HouseEditPage extends StatefulWidget {
  final HouseModel house;

  const HouseEditPage({
    super.key,
    required this.house,
  });

  @override
  State<HouseEditPage> createState() => _HouseEditPageState();
}

class _HouseEditPageState extends State<HouseEditPage> {
  late TextEditingController houseNumberController;
  late TextEditingController mooController;
  late TextEditingController villageController;
  late TextEditingController subdistrictController;
  late TextEditingController districtController;
  late TextEditingController provinceController;
  late TextEditingController ownerNameController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  final ImagePicker imagePicker = ImagePicker();

  File? newHouseImage;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final house = widget.house;

    houseNumberController = TextEditingController(
      text: house.houseNumber,
    );

    mooController = TextEditingController(
      text: house.moo,
    );

    villageController = TextEditingController(
      text: house.village,
    );

    subdistrictController = TextEditingController(
      text: house.subdistrict,
    );

    districtController = TextEditingController(
      text: house.district,
    );

    provinceController = TextEditingController(
      text: house.province,
    );

    ownerNameController = TextEditingController(
      text: house.ownerName,
    );

    latitudeController = TextEditingController(
      text: house.latitude.toString(),
    );

    longitudeController = TextEditingController(
      text: house.longitude.toString(),
    );
  }

  @override
  void dispose() {
    houseNumberController.dispose();
    mooController.dispose();
    villageController.dispose();
    subdistrictController.dispose();
    districtController.dispose();
    provinceController.dispose();
    ownerNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.dispose();
  }

  // =========================================================
  // SELECT LOCATION
  // =========================================================

  Future<void> selectLocation() async {
    double? latitude;
    double? longitude;

    if (latitudeController.text.isNotEmpty &&
        longitudeController.text.isNotEmpty) {
      latitude = double.tryParse(
        latitudeController.text,
      );

      longitude = double.tryParse(
        longitudeController.text,
      );
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationPage(
          initialLatitude: latitude,
          initialLongitude: longitude,
        ),
      ),
    );

    if (result != null) {
      latitudeController.text =
          result.latitude.toString();

      longitudeController.text =
          result.longitude.toString();

      setState(() {});
    }
  }

  // =========================================================
  // SELECT IMAGE
  // =========================================================

  Future<void> selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),
                title: const Text(
                  'ถ่ายภาพใหม่',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                ),
                title: const Text(
                  'เลือกจากคลังรูปภาพ',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await selectFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // CAMERA
  // =========================================================

  Future<void> takePhoto() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        newHouseImage = File(image.path);
      });
    }
  }

  // =========================================================
  // GALLERY
  // =========================================================

  Future<void> selectFromGallery() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        newHouseImage = File(image.path);
      });
    }
  }

  // =========================================================
  // UPDATE HOUSE
  // =========================================================

  Future<void> updateHouse() async {
    if (houseNumberController.text.trim().isEmpty) {
      showMessage('กรุณากรอกบ้านเลขที่');
      return;
    }

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      showMessage('กรุณาเลือกตำแหน่งบ้าน');
      return;
    }

    final latitude = double.tryParse(
      latitudeController.text.trim(),
    );

    final longitude = double.tryParse(
      longitudeController.text.trim(),
    );

    if (latitude == null || longitude == null) {
      showMessage(
        'Latitude หรือ Longitude ไม่ถูกต้อง',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await ApiService.updateHousehold(
        id: widget.house.id,
        houseNumber:
            houseNumberController.text.trim(),
        moo: mooController.text.trim(),
        village:
            villageController.text.trim(),
        subdistrict:
            subdistrictController.text.trim(),
        district:
            districtController.text.trim(),
        province:
            provinceController.text.trim(),
        ownerName:
            ownerNameController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        image: newHouseImage,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'แก้ไขข้อมูลสำเร็จ',
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        showMessage(
          result['message'] ??
              'แก้ไขข้อมูลไม่สำเร็จ',
        );
      }
    } catch (e) {
      print(
        'UPDATE HOUSE ERROR: $e',
      );

      if (!mounted) return;

      showMessage(
        'เกิดข้อผิดพลาด: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: requiredField
              ? '$label *'
              : label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  // =========================================================
  // IMAGE WIDGET
  // =========================================================

  Widget buildHouseImage() {
    // ถ้ามีรูปใหม่
    if (newHouseImage != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.file(
          newHouseImage!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    // ถ้ามีรูปเดิมจาก Cloudinary
    if (widget.house.imagePath != null &&
        widget.house.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.network(
          widget.house.imagePath!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
              ),
            );
          },
        ),
      );
    }

    // ไม่มีรูป
    return const Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 50,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Text(
          'กดเพื่อเพิ่มรูปบ้าน',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แก้ไข Household',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            // =================================================
            // HOUSE INFORMATION
            // =================================================

            buildTextField(
              label: 'บ้านเลขที่',
              controller:
                  houseNumberController,
              requiredField: true,
            ),

            buildTextField(
              label: 'หมู่',
              controller: mooController,
            ),

            buildTextField(
              label: 'หมู่บ้าน',
              controller:
                  villageController,
            ),

            buildTextField(
              label: 'ตำบล',
              controller:
                  subdistrictController,
            ),

            buildTextField(
              label: 'อำเภอ',
              controller:
                  districtController,
            ),

            buildTextField(
              label: 'จังหวัด',
              controller:
                  provinceController,
            ),

            buildTextField(
              label: 'เจ้าของบ้าน',
              controller:
                  ownerNameController,
            ),

            // =================================================
            // LOCATION
            // =================================================

            const SizedBox(height: 5),

            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'พิกัดบ้าน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            buildTextField(
              label: 'Latitude',
              controller:
                  latitudeController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
                signed: true,
              ),
              requiredField: true,
            ),

            buildTextField(
              label: 'Longitude',
              controller:
                  longitudeController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
                signed: true,
              ),
              requiredField: true,
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed:
                    selectLocation,
                icon: const Icon(
                  Icons.location_on,
                ),
                label: const Text(
                  '📍 เลือกตำแหน่งจากแผนที่',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // =================================================
            // HOUSE IMAGE
            // =================================================

            const SizedBox(height: 20),

            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'ภาพครัวเรือน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: selectImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: buildHouseImage(),
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: selectImage,
              icon: const Icon(
                Icons.change_circle,
              ),
              label: Text(
                newHouseImage == null
                    ? 'เปลี่ยนรูปภาพ'
                    : 'เลือกรูปใหม่',
              ),
            ),

            // =================================================
            // SAVE
            // =================================================

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : updateHouse,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  isLoading
                      ? 'กำลังบันทึก...'
                      : 'บันทึกการแก้ไข',
                  style:
                      const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}