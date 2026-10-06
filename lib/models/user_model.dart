class UserModel {
  final int id;
  final String name;
  final String username;
  
  final String? imagePath;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    
    this.imagePath,
  });
}

