import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'exceptions.dart';

class ApiBaseHelper {
  final String _baseUrl = "https://api.unsplash.com/";

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(_baseUrl + url, headers: {
        HttpHeaders.authorizationHeader:
            "Client_ID d47eb5e2d163fc2a6b047108bd3b201bfcd8129a9aaa92cd7dac0777f8fd762a"
      });
      print(response.body);
      print(response.headers);
      print(response.request);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
