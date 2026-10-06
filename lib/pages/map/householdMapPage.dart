import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/house_model.dart';
import '../../services/api_service.dart';

class HouseholdMapPage extends StatefulWidget {
  const HouseholdMapPage({super.key});

  @override
  State<HouseholdMapPage> createState() =>
      _HouseholdMapPageState();
}

class _HouseholdMapPageState
    extends State<HouseholdMapPage> {

  GoogleMapController? mapController;

  // =========================================================
  // HOUSEHOLDS FROM API
  // =========================================================

  List<HouseModel> houses = [];

  Set<Marker> markers = {};

  bool isLoading = true;

  // ตำแหน่งเริ่มต้น
  static const LatLng defaultPosition = LatLng(
    17.1561,
    104.1465,
  );

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    loadHouses();
  }

  // =========================================================
  // LOAD HOUSEHOLDS FROM API
  // =========================================================

  Future<void> loadHouses() async {
    try {
      print('====================================');
      print('LOAD HOUSEHOLDS FOR MAP');
      print('====================================');

      final result =
          await ApiService.getHouseholds();

      print('MAP HOUSE RESULT: $result');

      if (!mounted) return;

      if (result['success'] == true) {

        final List data =
            result['households'] ?? [];

        final List<HouseModel> loadedHouses =
            data.map((house) {

          return HouseModel(
            id: house['id'],

            houseNumber:
                house['house_number'] ?? '',

            moo:
                house['moo'] ?? '',

            village:
                house['village'] ?? '',

            subdistrict:
                house['subdistrict'] ?? '',

            district:
                house['district'] ?? '',

            province:
                house['province'] ?? '',

            ownerName:
                house['owner_name'] ?? '',

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

            imagePath:
                house['image_path'],
          );

        }).toList();

        setState(() {
          houses = loadedHouses;

          markers =
              getHouseMarkers();

          isLoading = false;
        });

        // ถ้ามีบ้าน ให้เลื่อนไปบ้านหลังแรก
        if (houses.isNotEmpty) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              if (!mounted) return;

              mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(
                    houses.first.latitude,
                    houses.first.longitude,
                  ),
                  14,
                ),
              );
            },
          );
        }

      } else {

        setState(() {
          isLoading = false;
        });

        showMessage(
          result['message'] ??
              'ไม่สามารถโหลดข้อมูลครัวเรือนได้',
        );
      }

    } catch (e) {

      print(
        'LOAD MAP HOUSE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'เกิดข้อผิดพลาด: $e',
      );
    }
  }

  // =========================================================
  // CREATE MARKERS
  // =========================================================

  Set<Marker> getHouseMarkers() {

    return houses.map((house) {

      return Marker(

        markerId: MarkerId(
          'house_${house.id}',
        ),

        position: LatLng(
          house.latitude,
          house.longitude,
        ),

        infoWindow: InfoWindow(
          title:
              'บ้านเลขที่ ${house.houseNumber}',

          snippet:
              'เจ้าของ: ${house.ownerName}',
        ),

        onTap: () {
          showHouseDetail(house);
        },
      );

    }).toSet();
  }

  // =========================================================
  // HOUSE DETAIL POPUP
  // =========================================================

  void showHouseDetail(
    HouseModel house,
  ) {

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =================================================
                // HOUSE IMAGE
                // =================================================

                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),

                  child:
                      house.imagePath != null &&
                              house.imagePath!
                                  .isNotEmpty

                          ? Image.network(
                              house.imagePath!,

                              width:
                                  double.infinity,

                              height: 280,

                              fit: BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  width:
                                      double.infinity,

                                  height: 280,

                                  color: Colors
                                      .grey
                                      .shade200,

                                  child:
                                      const Icon(
                                    Icons.home,
                                    size: 80,
                                    color:
                                        Colors.grey,
                                  ),
                                );
                              },
                            )

                          : Container(
                              width:
                                  double.infinity,

                              height: 280,

                              color:
                                  Colors.grey
                                      .shade200,

                              child:
                                  const Icon(
                                Icons.home,
                                size: 80,
                                color:
                                    Colors.grey,
                              ),
                            ),
                ),

                // =================================================
                // HOUSE INFORMATION
                // =================================================

                Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        'บ้านเลขที่ ${house.houseNumber}',

                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        'เจ้าของบ้าน: '
                        '${house.ownerName}',

                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'หมู่ ${house.moo} '
                        '${house.village}',

                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        '${house.subdistrict} '
                        '${house.district} '
                        '${house.province}',

                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Divider(),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        'พิกัดบ้าน',

                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Latitude: '
                        '${house.latitude}',
                      ),

                      Text(
                        'Longitude: '
                        '${house.longitude}',
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =================================================
                      // SHOW LOCATION
                      // =================================================

                      SizedBox(
                        width:
                            double.infinity,

                        height: 48,

                        child:
                            ElevatedButton.icon(

                          onPressed: () {

                            Navigator.pop(
                              context,
                            );

                            mapController
                                ?.animateCamera(

                              CameraUpdate
                                  .newLatLngZoom(

                                LatLng(
                                  house.latitude,
                                  house.longitude,
                                ),

                                18,
                              ),
                            );
                          },

                          icon:
                              const Icon(
                            Icons.location_on,
                          ),

                          label:
                              const Text(
                            'แสดงตำแหน่งบ้าน',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // =================================================
                      // CLOSE
                      // =================================================

                      SizedBox(
                        width:
                            double.infinity,

                        height: 45,

                        child:
                            OutlinedButton(

                          onPressed: () {

                            Navigator.pop(
                              context,
                            );
                          },

                          child:
                              const Text(
                            'ปิด',
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

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
    String message,
  ) {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    // ตำแหน่งเริ่มต้น
    final LatLng initialPosition =
        houses.isNotEmpty
            ? LatLng(
                houses.first.latitude,
                houses.first.longitude,
              )
            : defaultPosition;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Household Map',
        ),

        actions: [

          // ปุ่ม Refresh
          IconButton(
            onPressed:
                isLoading
                    ? null
                    : loadHouses,

            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [

          // =================================================
          // GOOGLE MAP
          // =================================================

          GoogleMap(

            initialCameraPosition:
                CameraPosition(
              target:
                  initialPosition,

              zoom: 14,
            ),

            markers: markers,

            mapType:
                MapType.normal,

            myLocationEnabled:
                false,

            zoomControlsEnabled:
                true,

            onMapCreated:
                (
              GoogleMapController
                  controller,
            ) {

              mapController =
                  controller;
            },
          ),

          // =================================================
          // LOADING
          // =================================================

          if (isLoading)

            Container(
              color: Colors.black
                  .withValues(
                alpha: 0.2,
              ),

              child:
                  const Center(
                child:
                    CircularProgressIndicator(),
              ),
            ),

          // =================================================
          // HOUSE COUNT
          // =================================================

          if (!isLoading)

            Positioned(
              top: 15,
              left: 15,

              child: Card(
                elevation: 4,

                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      const Icon(
                        Icons.home,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        'มี ${houses.length} ครัวเรือน',

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}