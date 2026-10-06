import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://finalapp-api-and-database-production.up.railway.app';

  // =========================================================
  // LOGIN
  // =========================================================

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN RESPONSE: ${response.body}');

    return jsonDecode(response.body);
  }

  // =========================================================
  // REGISTER
  // ส่งข้อมูล + รูปภาพแบบ Multipart
  // =========================================================

  static Future<Map<String, dynamic>> register(
    String name,
    String username,
    String password,
    File image,
  ) async {
    // สร้าง Multipart Request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/register'),
    );

    // =======================================================
    // TEXT DATA
    // =======================================================

    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['password'] = password;

    // =======================================================
    // IMAGE
    // =======================================================

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    print('====================================');
    print('REGISTER REQUEST');
    print('Name: $name');
    print('Username: $username');
    print('Image: ${image.path}');
    print('====================================');

    // =======================================================
    // SEND REQUEST
    // =======================================================

    final streamedResponse = await request.send();

    // แปลง Stream เป็น Response ปกติ
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print('====================================');
    print('REGISTER RESPONSE');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('====================================');

    // =======================================================
    // RETURN JSON
    // =======================================================

    return jsonDecode(response.body);
  }

  // =========================================================
  // GET USERS
  // =========================================================

  static Future<Map<String, dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users'),
    );

    print('GET USERS STATUS: ${response.statusCode}');
    print('GET USERS RESPONSE: ${response.body}');

    return jsonDecode(response.body);
  }

  // =========================================================
  // GET USER BY ID
  // =========================================================

  static Future<Map<String, dynamic>> getUser(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$id'),
    );

    print('GET USER STATUS: ${response.statusCode}');
    print('GET USER RESPONSE: ${response.body}');

    return jsonDecode(response.body);
  }

  // =========================================================
// HOUSEHOLD
// =========================================================

static Future<Map<String, dynamic>> getHouseholds() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/households'),
  );

  print('GET HOUSEHOLDS STATUS: ${response.statusCode}');
  print('GET HOUSEHOLDS RESPONSE: ${response.body}');

  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> getHousehold(
  int id,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/households/$id'),
  );

  print('GET HOUSEHOLD STATUS: ${response.statusCode}');
  print('GET HOUSEHOLD RESPONSE: ${response.body}');

  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> addHousehold({
  required String houseNumber,
  required String moo,
  required String village,
  required String subdistrict,
  required String district,
  required String province,
  required String ownerName,
  required double latitude,
  required double longitude,
  required File image,
}) async {
  // =========================================================
  // MULTIPART REQUEST
  // =========================================================

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/api/households'),
  );

  // =========================================================
  // TEXT DATA
  // =========================================================

  request.fields['house_number'] = houseNumber;
  request.fields['moo'] = moo;
  request.fields['village'] = village;
  request.fields['subdistrict'] = subdistrict;
  request.fields['district'] = district;
  request.fields['province'] = province;
  request.fields['owner_name'] = ownerName;
  request.fields['latitude'] = latitude.toString();
  request.fields['longitude'] = longitude.toString();

  // =========================================================
  // HOUSEHOLD IMAGE
  // =========================================================

  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      image.path,
    ),
  );

  print('====================================');
  print('ADD HOUSEHOLD REQUEST');
  print('House Number: $houseNumber');
  print('Moo: $moo');
  print('Village: $village');
  print('Owner: $ownerName');
  print('Latitude: $latitude');
  print('Longitude: $longitude');
  print('Image: ${image.path}');
  print('====================================');

  // =========================================================
  // SEND
  // =========================================================

  final streamedResponse = await request.send();

  // แปลง Stream เป็น Response ปกติ
  final response = await http.Response.fromStream(
    streamedResponse,
  );

  print('====================================');
  print('ADD HOUSEHOLD RESPONSE');
  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');
  print('====================================');

  if (response.statusCode >= 200 && response.statusCode < 300) {
  try {
    return jsonDecode(response.body);
  } catch (e) {
    print('JSON DECODE ERROR: $e');
    print('SERVER RESPONSE: ${response.body}');

    return {
      'success': false,
      'message': 'Server ส่งข้อมูลไม่ใช่ JSON',
    };
  }
} else {
  print('====================================');
  print('SERVER ERROR');
  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');
  print('====================================');

  return {
    'success': false,
    'message':
        'Server Error ${response.statusCode}: ${response.body}',
  };
}
}

static Future<Map<String, dynamic>> updateHousehold({
  required int id,
  required String houseNumber,
  required String moo,
  required String village,
  required String subdistrict,
  required String district,
  required String province,
  required String ownerName,
  required double latitude,
  required double longitude,
  File? image,
}) async {
  final request = http.MultipartRequest(
    'PUT',
    Uri.parse('$baseUrl/api/households/$id'),
  );

  // =========================================================
  // TEXT DATA
  // =========================================================

  request.fields['house_number'] = houseNumber;
  request.fields['moo'] = moo;
  request.fields['village'] = village;
  request.fields['subdistrict'] = subdistrict;
  request.fields['district'] = district;
  request.fields['province'] = province;
  request.fields['owner_name'] = ownerName;
  request.fields['latitude'] = latitude.toString();
  request.fields['longitude'] = longitude.toString();

  // =========================================================
  // NEW IMAGE
  // =========================================================

  if (image != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );
  }

  print('====================================');
  print('UPDATE HOUSEHOLD');
  print('ID: $id');
  print('House: $houseNumber');
  print('Owner: $ownerName');
  print('Latitude: $latitude');
  print('Longitude: $longitude');
  print('New Image: ${image?.path ?? 'ใช้รูปเดิม'}');
  print('====================================');

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  print('====================================');
  print('UPDATE HOUSE RESPONSE');
  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');
  print('====================================');

  try {
    return jsonDecode(response.body);
  } catch (e) {
    print(
      'UPDATE JSON ERROR: $e',
    );

    return {
      'success': false,
      'message':
          'Server ส่งข้อมูลไม่ใช่ JSON',
    };
  }
}
static Future<Map<String, dynamic>> deleteHousehold(
  int id,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/households/$id'),
  );

  print('DELETE HOUSEHOLD STATUS: ${response.statusCode}');
  print('DELETE HOUSEHOLD RESPONSE: ${response.body}');

  return jsonDecode(response.body);
}
}