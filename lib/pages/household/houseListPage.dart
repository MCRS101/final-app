import 'package:flutter/material.dart';

import '../../models/house_model.dart';
import '../../services/api_service.dart';
import 'houseAddPage.dart';
import 'houseEditPage.dart';

class HouseListPage extends StatefulWidget {
  const HouseListPage({super.key});

  @override
  State<HouseListPage> createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  List<HouseModel> houses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHouses();
  }

  // =========================================================
  // LOAD HOUSEHOLDS
  // =========================================================

  Future<void> loadHouses() async {
    try {
      final result = await ApiService.getHouseholds();

      print('HOUSEHOLD RESULT: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final List data = result['households'] ?? [];

        setState(() {
          houses = data.map((house) {
            return HouseModel(
              id: house['id'],
              houseNumber: house['house_number'] ?? '',
              moo: house['moo'] ?? '',
              village: house['village'] ?? '',
              subdistrict: house['subdistrict'] ?? '',
              district: house['district'] ?? '',
              province: house['province'] ?? '',
              ownerName: house['owner_name'] ?? '',
              latitude:
                  double.tryParse(
                    house['latitude'].toString(),
                  ) ??
                  0.0,
              longitude:
                  double.tryParse(
                    house['longitude'].toString(),
                  ) ??
                  0.0,
              imagePath: house['image_path'],
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
      print('LOAD HOUSEHOLD ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถโหลดข้อมูลครัวเรือนได้',
          ),
        ),
      );
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteHouse(HouseModel house) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text(
            'ต้องการลบบ้านเลขที่ ${house.houseNumber} หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final result = await ApiService.deleteHousehold(
        house.id,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบข้อมูลสำเร็จ'),
          ),
        );

        loadHouses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'ลบข้อมูลไม่สำเร็จ',
            ),
          ),
        );
      }
    } catch (e) {
      print('DELETE HOUSE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาด'),
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
      appBar: AppBar(
        title: const Text('Household'),
      ),

      // ADD
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HouseAddPage(),
            ),
          );

          if (result == true) {
            loadHouses();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : houses.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadHouses,
                  child: ListView(
                    children: const [
                      SizedBox(height: 180),
                      Icon(
                        Icons.home_work_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Text(
                          'ยังไม่มีข้อมูลครัวเรือน',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadHouses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: houses.length,
                    itemBuilder: (context, index) {
                      final house = houses[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(12),
                          onTap: () {
  showHouseDetail(house);
},
                          leading: CircleAvatar(
                              radius: 28,
                          backgroundImage:
                          house.imagePath != null &&
                          house.imagePath!.isNotEmpty
                          ? NetworkImage(house.imagePath!)
                          : null,
                      child:
                      house.imagePath == null ||
              house.imagePath!.isEmpty
          ? const Icon(
              Icons.home,
            )
          : null,
                          ),

                          title: Text(
                            'บ้านเลขที่ ${house.houseNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            'หมู่บ้าน ${house.village}\n'
                            'หมู่ ${house.moo} '
                            'ตำบล ${house.subdistrict}\n'
                            'อำเภอ ${house.district}\n'
                            'จังหวัด ${house.province}\n'
                            'เจ้าของ: ${house.ownerName}',
                          ),

                          isThreeLine: true,

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HouseEditPage(
                                      house: house,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  loadHouses();
                                }
                              }

                              if (value == 'delete') {
                                deleteHouse(house);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text('แก้ไข'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text('ลบ'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
  // =========================================================
// HOUSE DETAIL POPUP
// =========================================================

void showHouseDetail(HouseModel house) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // =================================================
              // HOUSE IMAGE
              // =================================================

              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: house.imagePath != null &&
                        house.imagePath!.isNotEmpty
                    ? Image.network(
                        house.imagePath!,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 280,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 70,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 280,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.home,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
              ),

              // =================================================
              // HOUSE INFORMATION
              // =================================================

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      'บ้านเลขที่ ${house.houseNumber}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'หมู่ที่ ${house.moo}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'หมู่บ้าน: ${house.village}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'ตำบล: ${house.subdistrict}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'อำเภอ: ${house.district}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'จังหวัด: ${house.province}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'เจ้าของบ้าน: ${house.ownerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Divider(),

                    const SizedBox(height: 10),

                    const Text(
                      'พิกัดบ้าน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Latitude: ${house.latitude}',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    Text(
                      'Longitude: ${house.longitude}',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // CLOSE BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'ปิด',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}