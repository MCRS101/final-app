import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const SelectLocationPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<SelectLocationPage> createState() =>
      _SelectLocationPageState();
}

class _SelectLocationPageState
    extends State<SelectLocationPage> {

  late GoogleMapController mapController;

  LatLng? selectedLocation;

  // ตำแหน่งเริ่มต้น
  static const LatLng defaultLocation = LatLng(
    17.1561,
    104.1465,
  );

  @override
  void initState() {
    super.initState();

    if (widget.initialLatitude != null &&
        widget.initialLongitude != null) {
      selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
  }

  // =========================================================
  // เลือกตำแหน่ง
  // =========================================================

  void selectLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  // =========================================================
  // ยืนยันตำแหน่ง
  // =========================================================

  void confirmLocation() {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากดเลือกตำแหน่งบนแผนที่',
          ),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      selectedLocation,
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    final LatLng startLocation =
        selectedLocation ?? defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เลือกตำแหน่งครัวเรือน',
        ),
      ),

      body: Stack(
        children: [

          // ===================================================
          // GOOGLE MAP
          // ===================================================

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: startLocation,
              zoom: 15,
            ),

            mapType: MapType.normal,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onTap: selectLocation,

            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId:
                          const MarkerId('house'),
                      position:
                          selectedLocation!,
                    ),
                  },
          ),

          // ===================================================
          // LAT LONG แสดงด้านบน
          // ===================================================

          Positioned(
            top: 15,
            left: 15,
            right: 15,

            child: Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: selectedLocation == null
                    ? const Text(
                        '📍 กดบนแผนที่เพื่อเลือกตำแหน่งบ้าน',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'ตำแหน่งที่เลือก',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Latitude: '
                            '${selectedLocation!.latitude}',
                          ),

                          Text(
                            'Longitude: '
                            '${selectedLocation!.longitude}',
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // ===================================================
          // ปุ่มยืนยัน
          // ===================================================

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,

            child: SizedBox(
              height: 52,

              child: ElevatedButton.icon(
                onPressed: confirmLocation,

                icon: const Icon(
                  Icons.check,
                ),

                label: const Text(
                  'ยืนยันตำแหน่ง',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}