
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skripsi/models/userModel.dart';

class UserRepository {
  static const String baseUrl =
      "http://localhost:3000/endpoint/pemilih/";

  // Future<List<User>> getAllUsers() async {
  //   var response = await http.get("$baseUrl/get_all");
  //   Iterable userList = json.decode(response.body);
  //   List<User> users = userList.map((user) => User.fromJson(user)).toList();
  //   return users;
  // }

  Future<User> getUserById(String id) async {
    // var response = await http.get("$baseUrl/get_data_pemilih");
    // var jsonUser = json.decode(response.body);
    // User user = User.fromJson(jsonUser);
    // return user;
  }

  // Future<bool> createUser(tagID) async {
  //   var response = await http.post(
  //     "$baseUrl/add_new_pemilih",
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'TagID': tagID,
  //     }),
  //   );
  //
  //   return response.statusCode == 200;
  // }

  // Future<bool> updateUser(User user) async {
  //   var response = await http.put(
  //     "$baseUrl/users/${user.id}?$apiKey",
  //     headers: {"Content-Type": "application/json"},
  //     body: json.encode(user.toJson()),
  //   );
  //   return response.statusCode == 200;
  // }
  //
  // Future<bool> deleteUser(String id) async {
  //   var response = await http.delete("$baseUrl/users/$id?$apiKey");
  //   return response.statusCode == 200;
  // }
}