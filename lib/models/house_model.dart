
class HouseModel {
  int id;

  String houseNumber;
  String moo;
  String village;
  String subdistrict;
  String district;
  String province;
  String ownerName;

  double latitude;
  double longitude;

  String? imagePath;

  HouseModel({
    required this.id,
    required this.houseNumber,
    required this.moo,
    required this.village,
    required this.subdistrict,
    required this.district,
    required this.province,
    required this.ownerName,
    required this.latitude,
    required this.longitude,
    this.imagePath,
  });
}

