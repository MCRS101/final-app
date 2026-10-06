import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import 'selectLocationPage.dart';

class HouseAddPage extends StatefulWidget {
  const HouseAddPage({super.key});

  @override
  State<HouseAddPage> createState() => _HouseAddPageState();
}

class _HouseAddPageState extends State<HouseAddPage> {
  final houseNumberController = TextEditingController();
  final mooController = TextEditingController();
  final villageController = TextEditingController();
  final subdistrictController = TextEditingController();
  final districtController = TextEditingController();
  final provinceController = TextEditingController();
  final ownerNameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // =========================================================
  // IMAGE
  // =========================================================

  final ImagePicker imagePicker = ImagePicker();

  File? houseImage;

  bool isLoading = false;

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
  // IMAGE MENU
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
                  'ถ่ายภาพ',
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
        houseImage = File(image.path);
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
        houseImage = File(image.path);
      });
    }
  }

  // =========================================================
  // ADD HOUSE
  // =========================================================

  Future<void> addHouse() async {
    if (houseNumberController.text.trim().isEmpty) {
      showMessage('กรุณากรอกบ้านเลขที่');
      return;
    }

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      showMessage(
        'กรุณาเลือกตำแหน่งบ้าน',
      );
      return;
    }

    if (houseImage == null) {
      showMessage(
        'กรุณาถ่ายรูปหรือเลือกรูปครัวเรือน',
      );
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
          await ApiService.addHousehold(
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
        image: houseImage!,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'เพิ่มข้อมูลครัวเรือนสำเร็จ',
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      } else {
        showMessage(
          result['message'] ??
              'เพิ่มข้อมูลไม่สำเร็จ',
        );
      }
    } catch (e) {
      print(
        'ADD HOUSE ERROR: $e',
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
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
      padding:
          const EdgeInsets.only(bottom: 14),
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
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่ม Household',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            buildTextField(
              label: 'บ้านเลขที่',
              controller:
                  houseNumberController,
              requiredField: true,
            ),

            buildTextField(
              label: 'หมู่',
              controller:
                  mooController,
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
              child:
                  OutlinedButton.icon(
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

            const SizedBox(height: 20),

            // =================================================
            // HOUSE IMAGE
            // =================================================

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

                child: houseImage == null
                    ? Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: const [

                          Icon(
                            Icons
                                .add_a_photo,
                            size: 50,
                            color:
                                Colors.grey,
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'กดเพื่อถ่ายภาพ\nหรือเลือกรูปจากคลัง',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 16,
                            ),
                          ),

                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),

                        child: Image.file(
                          houseImage!,
                          width:
                              double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            if (houseImage != null)
              TextButton.icon(
                onPressed:
                    selectImage,
                icon: const Icon(
                  Icons.change_circle,
                ),
                label: const Text(
                  'เปลี่ยนรูปภาพ',
                ),
              ),

            const SizedBox(height: 15),

            // =================================================
            // SAVE
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : addHouse,

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
                      : 'บันทึกข้อมูล',
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