import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String _apiKey = '8748b1be209a46f18d03a5df54b08826';

  Future<List<Map<String, dynamic>>> fetchRecipes({String query = '', Map<String, String>? filters}) async {
    String filterString = '';

    if (filters != null) {
      filters.forEach((key, value) {
        filterString += '&$key=$value';
      });
    }

    final url =
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$_apiKey&query=$query$filterString';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load recipes');
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final url =
        'https://api.spoonacular.com/recipes/$recipeId/information?includeNutrition=true&apiKey=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load recipe details');
    }
  }
}
