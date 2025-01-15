import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/widgets/recipe_card.dart';

class CuisineRecipesScreen extends StatelessWidget {
  final String cuisine;

  CuisineRecipesScreen({required this.cuisine});

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final apiKey = '8748b1be209a46f18d03a5df54b08826';
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?cuisine=$cuisine&number=10&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final recipes = data['results'] as List;

      return recipes.map((recipe) {
        return {
          "id": recipe['id'],
          "title": recipe['title'],
          "image": recipe['image'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$cuisine Tarifleri"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching recipes"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No recipes found"));
          } else {
            final recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  title: recipe["title"],
                  image: recipe["image"],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/recipeDetail',
                      arguments: recipe["id"],
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}