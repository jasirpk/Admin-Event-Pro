import 'dart:core';

class UserModel {
  String? email;
  String? password;
  String? uid;
  String? companyName;
  String? about;
  String? imagePath;
  String? phoneNumber;
  String? bussinessEmail;
  List<Map<String, dynamic>> images;
  List<Map<String, dynamic>> links;
  String? website;
  UserModel(
      {this.email,
      this.password,
      this.uid,
      this.companyName,
      this.about,
      this.imagePath = '',
      this.bussinessEmail,
      this.phoneNumber,
      this.images = const [],
      this.links = const []});
}
