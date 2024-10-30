import 'dart:convert';

import 'package:http/http.dart' as http;

class CountryService {
  Future<String> getCountryCode() async {
    final result = await Future.any([
      _getCountryCode(),
      Future.delayed(Duration(seconds: 5), () => "Delayed 5 seconds"),
    ]);
    
    return result;
  }


  Future<String> _getCountryCode() async {
    http.Response response = await http.get(Uri.parse('http://ip-api.com/json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['countryCode'] ?? 'VN';
    }

    return 'API Failed';
  }
}
