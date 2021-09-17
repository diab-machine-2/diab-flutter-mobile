import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';


part 'app_api.g.dart';

@RestApi()
abstract class AppApi {
  factory AppApi(Dio dio, {String baseUrl}) = _AppApi;

  // @POST("sign-in")
  // Future<LoginResponse> login(@Body() LoginRequest request);
}
