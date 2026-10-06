
import 'house_model.dart';

class HouseData {
  static final List<HouseModel> houses = [
    HouseModel(
      id: 1,
      houseNumber: '123',
      moo: '1',
      village: 'บ้านสุขใจ',
      subdistrict: 'ธาตุเชิงชุม',
      district: 'เมืองสกลนคร',
      province: 'สกลนคร',
      ownerName: 'สมชาย ใจดี',
      latitude: 17.1561,
      longitude: 104.1465,
    ),

    HouseModel(
      id: 2,
      houseNumber: '45',
      moo: '2',
      village: 'บ้านนา',
      subdistrict: 'ดงมะไฟ',
      district: 'เมืองสกลนคร',
      province: 'สกลนคร',
      ownerName: 'สมหญิง ใจดี',
      latitude: 17.1800,
      longitude: 104.1600,
    ),
  ];
}

