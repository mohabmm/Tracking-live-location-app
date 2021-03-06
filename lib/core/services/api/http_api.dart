import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testmovie/core/models/login.dart';
import 'package:testmovie/core/models/main_data.dart';
import 'package:testmovie/core/models/registiration_data.dart';
import 'package:testmovie/core/services/api/api.dart';
import 'package:testmovie/ui/utilities/show_snack_bar.dart';
import 'package:testmovie/ui/views/home_view.dart';

class HttpApi implements Api {
  static const apiKey = "";

  StreamController<List<MainData>> mainItemsController = new BehaviorSubject();

  Stream<List<MainData>> get mainDataStream => mainItemsController.stream;

  
  var client = new http.Client();

  static const endpointLogin = '';
  static const endpointSignUp = '';
  static const getMainDataEndPoint =
      '';
  static const codistaEndpointGetAllMovies =
      '';
  static const codistaEndpointGetSingleMovie =
      '';

  final prefs = SharedPreferences.getInstance();

  @override
  Future<UserSignUpData> signUp(Map body, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    return http
        .post(endpointSignUp, body: body)
        .then((http.Response response) async {
      final int statusCode = response.statusCode;
      print('Response body is : ${response.body}');

      Map responses = json.decode(response.body);

      if (statusCode == 200) {
        showSnackBar('User Registered Successfully');
        Navigator.pushReplacementNamed(context, 'signinformem');
        return;
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        print("error found");
      }
      throw new Exception("Error while fetching data");
    });
  }

  @override
  Future<Login> logIn(Map body, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    return http
        .post(endpointLogin, body: body)
        .then((http.Response response) async {
      final int statusCode = response.statusCode;
      print('Response body is : ${response.body}');

      Map responses = json.decode(response.body);

      String token = responses["token"];
      prefs.setString('my_string_key', token);
      print("the token is " + token);
      if (statusCode == 200) {
        showSnackBar('User Registered Successfully ');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeView()),
            (Route<dynamic> route) => false);

//        Navigator.pushReplacementNamed(context, 'homeview');
        return;
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        print("error found");
      }
      throw new Exception("Error while fetching data");
    });
  }

  @override
  Future<List<MainData>> getMainData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userToken = prefs.getString('my_string_key') ?? '';

    print("the user token inside the get main data is" + userToken);

    var posts = List<MainData>();
    final response =
        await http.post(getMainDataEndPoint, body: {'token': userToken});
    final parsed = json.decode(response.body) as Map<String, dynamic>;
    posts.add(MainData.fromJson(parsed));
    mainItemsController.add(posts);

    print("the main data are " + parsed.toString());
    final int statusCode = response.statusCode;
//    posts.add(MainData.fromJson(post));
    return posts;
  }

  addFunction(String s) {}

  @override
  Stream<List<MainData>> getMainDataStream() {
    getMainData();
    return mainDataStream;
  }
}
