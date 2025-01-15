import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';

class CanIScreen extends StatefulWidget {
  @override
  _CanIScreenState createState() => _CanIScreenState();
}

class _CanIScreenState extends State<CanIScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ingredients = _ingredientsController.text.split('-').map((e) => e.trim()).join(',');
      final recipes = await _apiService.fetchRecipes(query: '', filters: {'includeIngredients': ingredients});

      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching recipes: $e'),
      ));
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
        title: Text('Can I Cook?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (separated by -)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRecipes,
              child: Text('Find Recipes'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _recipes.isEmpty
                        ? Center(child: Text('No recipes found.'))
                        : ListView.builder(
                            itemCount: _recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _recipes[index];
                              return RecipeCard(
                                title: recipe['title'],
                                image: recipe['image'],
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/recipeDetail',
                                    arguments: recipe['id'],
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
