import 'dart:convert';
import 'package:http/http.dart' as http;

class NhtsaApiService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin';

  Future<Map<String, String?>> decodeVin(String vin) async {
    final url = Uri.parse('$_baseUrl/$vin?format=json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['Results'];

        String? make;
        String? model;
        String? year;
        String? trim;
        String? series;
        String? engineModel;
        String? displacementL;
        String? cylinders;
        String? configuration;

        for (var item in results) {
          final variable = item['Variable'];
          final value = item['Value'] as String?;

          if (value == null || value.isEmpty || value == 'null') continue;

          switch (variable) {
            case 'Make':
              make = value;
              break;
            case 'Model':
              model = value;
              break;
            case 'Model Year':
              year = value;
              break;
            case 'Trim':
              trim = value;
              break;
            case 'Series':
              series = value;
              break;
            case 'Engine Model':
              engineModel = value;
              break;
            case 'Displacement (L)':
              displacementL = value;
              break;
            case 'Engine Number of Cylinders':
              cylinders = value;
              break;
            case 'Engine Configuration':
              configuration = value;
              break;
          }
        }

        // Construct Engine Description
        // Example goal: "LSA 6.2L V8"
        final List<String> engineParts = [];
        if (engineModel != null) engineParts.add(engineModel);
        if (displacementL != null) engineParts.add('${displacementL}L');

        if (configuration != null && cylinders != null) {
             // Try to make "V8", "I4", etc if configuration is "V-Shaped" or "Inline"
             String configShort = '';
             if (configuration.toUpperCase().contains('V-SHAPED')) configShort = 'V';
             else if (configuration.toUpperCase().contains('INLINE')) configShort = 'I';
             else if (configuration.toUpperCase().contains('FLAT')) configShort = 'H'; // Boxer/Flat

             if (configShort.isNotEmpty) {
                 engineParts.add('$configShort$cylinders');
             } else {
                 engineParts.add('$cylinders Cylinders');
             }
        } else if (cylinders != null) {
            engineParts.add('$cylinders Cylinders');
        }

        final engineDescription = engineParts.isNotEmpty ? engineParts.join(' ') : null;

        return {
          'make': make,
          'model': model,
          'year': year,
          'trim': trim,
          'series': series,
          'engine': engineDescription,
        };
      } else {
        throw Exception('Failed to load VIN data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to VIN service: $e');
    }
  }
}
