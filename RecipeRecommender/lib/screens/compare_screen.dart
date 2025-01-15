import 'package:flutter/material.dart';
import '../services/api_service.dart';
class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}
class _CompareScreenState extends State<CompareScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  List<int> _selectedRecipes = [];
  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }
  void _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> recipes = await _apiService.fetchRecipes();
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
  void _toggleSelection(int recipeId) {
    setState(() {
      if (_selectedRecipes.contains(recipeId)) {
        _selectedRecipes.remove(recipeId);
      } else if (_selectedRecipes.length < 2) {
        _selectedRecipes.add(recipeId);
      }
    });
  }

  void _compareSelectedRecipes() async {
    if (_selectedRecipes.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select exactly two recipes to compare.")),
      );
      return;
    }

    final recipeDetails = await Future.wait(
      _selectedRecipes.map((id) => _apiService.fetchRecipeDetails(id)),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeComparisonScreen(recipeDetails: recipeDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Compare Recipes")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      final isSelected = _selectedRecipes.contains(recipe['id']);

                      return GestureDetector(
                        onTap: () => _toggleSelection(recipe['id']),
                        child: Card(
                          color: isSelected ? Colors.green[100] : null,
                          child: ListTile(
                            leading: Image.network(
                              recipe['image'],
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(recipe['title']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _compareSelectedRecipes,
                    child: Text("Compare"),
                  ),
                ),
              ],
            ),
    );
  }
}

class RecipeComparisonScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipeDetails;

  RecipeComparisonScreen({required this.recipeDetails});

  @override
  Widget build(BuildContext context) {
    final recipe1 = recipeDetails[0];
    final recipe2 = recipeDetails[1];

    final ingredients1 = recipe1['extendedIngredients']
        .map<String>((e) => e['original'].toString())
        .toList();
    final ingredients2 = recipe2['extendedIngredients']
        .map<String>((e) => e['original'].toString())
        .toList();

    final cuisines1 = recipe1['cuisines'] ?? [];
    final cuisines2 = recipe2['cuisines'] ?? [];

    final steps1 = recipe1['analyzedInstructions'].isNotEmpty
        ? recipe1['analyzedInstructions'][0]['steps']
            .map<String>((e) => e['step'].toString())
            .toList()
        : [];
    final steps2 = recipe2['analyzedInstructions'].isNotEmpty
        ? recipe2['analyzedInstructions'][0]['steps']
            .map<String>((e) => e['step'].toString())
            .toList()
        : [];

    final nutrients1 = List<Map<String, dynamic>>.from(recipe1['nutrition']['nutrients'] ?? []);
    final nutrients2 = List<Map<String, dynamic>>.from(recipe2['nutrition']['nutrients'] ?? []);

    final importantNutrients = ['Calories', 'Fat', 'Carbohydrates', 'Sugar', 'Protein'];

    final filteredNutrients1 = nutrients1
        .where((nutrient) => importantNutrients.contains(nutrient['name']))
        .toList();
    final filteredNutrients2 = nutrients2
        .where((nutrient) => importantNutrients.contains(nutrient['name']))
        .toList();

    Color _compareColor(dynamic value1, dynamic value2) {
      if (value1 is num && value2 is num) {
        return value1 < value2 ? Colors.green : (value1 > value2 ? Colors.red : Colors.black);
      }
      return Colors.black;
    }

    Color _compareNColor(dynamic value1, dynamic value2) {
      if (value1 is num && value2 is num) {
        return value1 > value2 ? Colors.green : (value1 < value2 ? Colors.red : Colors.black);
      }
      return Colors.black;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Recipe Comparison")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recipe: ${recipe1['title']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Ready in: ${recipe1['readyInMinutes']} minutes",
                style: TextStyle(color: _compareColor(recipe1['readyInMinutes'], recipe2['readyInMinutes']))),
            Text("Cuisines: ${cuisines1.join(', ')}", style: TextStyle(color: Colors.black)),
            SizedBox(height: 8),
            ...ingredients1.map((ingredient) => Text(
                  ingredient,
                  style: TextStyle(color: _compareColor(ingredients1.length, ingredients2.length)),
                )),
            Divider(),
            ...steps1.map((step) => Text(
                  step,
                  style: TextStyle(color: _compareColor(steps1.length, steps2.length)),
                )),
            Divider(),

            Text("Nutrition Info:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...filteredNutrients1.map((nutrient) {
              final nutrientName = nutrient['name'];
              final nutrient1Value = nutrient['amount'];
              final nutrient2Value = filteredNutrients2.firstWhere(
                (n) => n['name'] == nutrientName,
                orElse: () => {'amount': 0},
              )['amount'];
              return Text(
                "$nutrientName: $nutrient1Value",
                style: TextStyle(color: _compareNColor(nutrient1Value, nutrient2Value)),
              );
            }),
            Divider(thickness: 2),

            Text("Recipe: ${recipe2['title']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Ready in: ${recipe2['readyInMinutes']} minutes",
                style: TextStyle(color: _compareColor(recipe2['readyInMinutes'], recipe1['readyInMinutes']))),
            Text("Cuisines: ${cuisines2.join(', ')}", style: TextStyle(color: Colors.black)),
            SizedBox(height: 8),
            ...ingredients2.map((ingredient) => Text(
                  ingredient,
                  style: TextStyle(color: _compareColor(ingredients2.length, ingredients1.length)),
                )),
            Divider(),
            ...steps2.map((step) => Text(
                  step,
                  style: TextStyle(color: _compareColor(steps2.length, steps1.length)),
                )),
            Divider(),

            Text("Nutrition Info:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...filteredNutrients2.map((nutrient) {
              final nutrientName = nutrient['name'];
              final nutrient2Value = nutrient['amount'];
              final nutrient1Value = filteredNutrients1.firstWhere(
                (n) => n['name'] == nutrientName,
                orElse: () => {'amount': 0},
              )['amount'];
              return Text(
                "$nutrientName: $nutrient2Value",
                style: TextStyle(color: _compareNColor(nutrient2Value, nutrient1Value)),
              );
            }),
          ],
        ),
      ),
    );
  }
}
