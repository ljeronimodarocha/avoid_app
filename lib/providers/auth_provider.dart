import 'dart:async' show Future, Timer;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/store.dart';
import '../exceptions/firebase_exception.dart';

class AuthProvider with ChangeNotifier {
  String? _userID;
  String? _token;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return isAuth ? _userID : null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String username, password, String urlSegment) async {
    final String _url = "http://192.168.15.9:3000/$urlSegment";

    final response = await http
        .post(
          Uri.parse(_url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': "*/*",
          },
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 5));
    final respondeBody = jsonDecode(response.body);
    if (respondeBody["error"] != null) {
      throw FireBaseException(respondeBody["error"]['message']);
    } else {
      _token = respondeBody["token"];
      _userID = respondeBody["userID"].toString();
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(respondeBody["expIn"].toString()),
        ),
      );

      Store.saveMap('userData', {
        "token": _token,
        "userID": _userID,
        "expiryDate": _expiryDate!.toIso8601String(),
      });

      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "usuarios");
  }

  Future<void> entrar(String email, String password) async {
    return _authenticate(email, password, "login");
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) {
      return Future.value();
    }
    final userData = await Store.getMap('userData');
    if (userData == null) {
      return Future.value();
    }

    final expiryDate = DateTime.parse(userData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return Future.value();
    }

    _userID = userData["userID"];
    _token = userData["token"];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
    return Future.value();
  }

  void logout() {
    _token = null as String;
    _userID = null as String;
    _expiryDate = null as DateTime;
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
      _logoutTimer = null as Timer;
    }
    Store.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }
    final timeToLogout = _expiryDate!.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
