import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorizedRequest(String? reason) = UnauthorizedRequest;

  const factory NetworkExceptions.badRequest() = BadRequest;

  const factory NetworkExceptions.notFound(String reason) = NotFound;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions handleResponse(dynamic data, int? statusCode) {
    String? message;
    if (data.toString().contains("errorMesssage")) {
      message = data["errorMesssage"];
    }
    if (data.toString().contains("message")) {
      message = data["message"];
    }
    switch (statusCode) {
      case 400:
      case 401:
      case 403:
        return NetworkExceptions.unauthorizedRequest(message);
      case 404:
        return NetworkExceptions.notFound(R.string.error_not_found_api.tr());
      case 409:
        return NetworkExceptions.conflict();
      case 408:
        return NetworkExceptions.requestTimeout();
      case 500:
        return NetworkExceptions.internalServerError();
      case 503:
        return NetworkExceptions.serviceUnavailable();
      default:
        var responseCode = statusCode;
        return NetworkExceptions.defaultError(R.string.error_invalid_status_code.tr(args: [responseCode.toString()]),);
    }
  }

  static NetworkExceptions getDioException(error) {
    if (error is Exception) {
      try {
        NetworkExceptions? networkExceptions;
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              networkExceptions = NetworkExceptions.requestCancelled();
              break;
            case DioExceptionType.connectionTimeout:
              networkExceptions = NetworkExceptions.requestTimeout();
              break;
            case DioExceptionType.receiveTimeout:
              networkExceptions = NetworkExceptions.sendTimeout();
              break;
            case DioExceptionType.sendTimeout:
              networkExceptions = NetworkExceptions.sendTimeout();
              break;
            case DioExceptionType.badResponse:
              networkExceptions =
                  NetworkExceptions.handleResponse(error.response?.data, error.response?.statusCode);
              break;
            case DioExceptionType.badCertificate:
            case DioExceptionType.connectionError:
            case DioExceptionType.unknown:
              networkExceptions = NetworkExceptions.noInternetConnection();
              break;
          }
        } else if (error is SocketException) {
          networkExceptions = NetworkExceptions.noInternetConnection();
        } else {
          networkExceptions = NetworkExceptions.unexpectedError();
        }
        return networkExceptions;
      } on FormatException {
        // Helper.printError(e.toString());
        return NetworkExceptions.formatException();
      } catch (_) {
        return NetworkExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return NetworkExceptions.unableToProcess();
      } else {
        return NetworkExceptions.unexpectedError();
      }
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = "";
    networkExceptions.when(notImplemented: () {
      errorMessage = R.string.error_not_implemented.tr();
    }, requestCancelled: () {
      errorMessage = R.string.error_request_canceled.tr();
    }, internalServerError: () {
      errorMessage = R.string.error_internet_server_error.tr();
    }, notFound: (String reason) {
      errorMessage = reason;
    }, serviceUnavailable: () {
      errorMessage = R.string.error_service_unavailable.tr();
    }, methodNotAllowed: () {
      errorMessage = R.string.error_method_not_allowed.tr();
    }, badRequest: () {
      errorMessage = R.string.error_bad_request.tr();
    }, unauthorizedRequest: (reason) {
      errorMessage = reason ?? R.string.error_unauthorized_request.tr();
    }, unexpectedError: () {
      errorMessage = R.string.error_unexpected_error.tr();
    }, requestTimeout: () {
      errorMessage = R.string.error_request_timeout.tr();
    }, noInternetConnection: () {
      errorMessage = R.string.error_no_network_connection.tr();
    }, conflict: () {
      errorMessage = R.string.error_conflict.tr();
    }, sendTimeout: () {
      errorMessage = R.string.error_send_timeout.tr();
    }, unableToProcess: () {
      errorMessage = R.string.error_unable_process_data.tr();
    }, defaultError: (String error) {
      errorMessage = error;
    }, formatException: () {
      errorMessage = R.string.error_unexpected_error.tr();
    }, notAcceptable: () {
      errorMessage = R.string.error_not_acceptable.tr();
    });
    return errorMessage;
  }
}