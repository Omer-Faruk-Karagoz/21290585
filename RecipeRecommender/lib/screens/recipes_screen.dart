import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipesScreen extends StatefulWidget {
  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _timeFilterController = TextEditingController();
  final TextEditingController _ingredientFilterController = TextEditingController();
  final TextEditingController _cuisineFilterController = TextEditingController();
  final TextEditingController _proteinFilterController = TextEditingController();
  final TextEditingController _fatFilterController = TextEditingController();
  final TextEditingController _caloriesFilterController = TextEditingController();
  final TextEditingController _sugarFilterController = TextEditingController();
  final TextEditingController _carbohydratesFilterController = TextEditingController();

  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes({String query = ''}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, String> filters = {};

      if (_timeFilterController.text.isNotEmpty) {
        final time = _timeFilterController.text.split('-');
        filters['maxReadyTime'] = time[1];
      }

      if (_ingredientFilterController.text.isNotEmpty) {
        filters['includeIngredients'] = _ingredientFilterController.text.replaceAll('-', ',');
      }

      if (_cuisineFilterController.text.isNotEmpty) {
        filters['cuisine'] = _cuisineFilterController.text;
      }

      if (_proteinFilterController.text.isNotEmpty) {
        final protein = _proteinFilterController.text.split('-');
        filters['minProtein'] = protein[0];
        filters['maxProtein'] = protein[1];
      }
      if (_fatFilterController.text.isNotEmpty) {
        final fat = _fatFilterController.text.split('-');
        filters['minFat'] = fat[0];
        filters['maxFat'] = fat[1];
      }
      if (_caloriesFilterController.text.isNotEmpty) {
        final calories = _caloriesFilterController.text.split('-');
        filters['minCalories'] = calories[0];
        filters['maxCalories'] = calories[1];
      }
      if (_sugarFilterController.text.isNotEmpty) {
        final sugar = _sugarFilterController.text.split('-');
        filters['minSugar'] = sugar[0];
        filters['maxSugar'] = sugar[1];
      }
      if (_carbohydratesFilterController.text.isNotEmpty) {
        final carbohydrates = _carbohydratesFilterController.text.split('-');
        filters['minCarbohydrates'] = carbohydrates[0];
        filters['maxCarbohydrates'] = carbohydrates[1];
      }

      List<Map<String, dynamic>> recipes = await _apiService.fetchRecipes(
        query: query,
        filters: filters,
      );

      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching recipes: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search recipes...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchRecipes(query: _searchController.text.trim());
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildFilterField("Required Time (min-max)", _timeFilterController),
                _buildFilterField("Ingredients (e.g., egg-vinegar-garlic)", _ingredientFilterController),
                _buildFilterField("Cuisine (e.g., Asian)", _cuisineFilterController),
                _buildFilterField("Protein (min-max)", _proteinFilterController),
                _buildFilterField("Fat (min-max)", _fatFilterController),
                _buildFilterField("Calories (min-max)", _caloriesFilterController),
                _buildFilterField("Sugar (min-max)", _sugarFilterController),
                _buildFilterField("Carbohydrates (min-max)", _carbohydratesFilterController),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _fetchRecipes(query: _searchController.text.trim());
                    },
                    child: Text("Apply Filters"),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            recipe['image'],
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(recipe['title']),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/recipeDetail',
                              arguments: recipe['id'],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilterField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
