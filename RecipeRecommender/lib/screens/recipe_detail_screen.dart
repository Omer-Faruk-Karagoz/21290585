import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int recipeId = ModalRoute.of(context)!.settings.arguments as int;
    final ApiService _apiService = ApiService();
    final FirebaseService _firebaseService = FirebaseService();
    final TextEditingController _commentController = TextEditingController();
    double _rating = 3.0;

    return FutureBuilder<Map<String, dynamic>>(
      future: _apiService.fetchRecipeDetails(recipeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Recipe Details")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Recipe Details")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        final recipe = Recipe.fromJson(snapshot.data!);

        final cuisines = recipe.cuisines.isNotEmpty
            ? recipe.cuisines.join(', ')
            : "No cuisines available.";

        final importantNutrients = ['Calories', 'Fat', 'Carbohydrates', 'Sugar', 'Protein'];
        final filteredNutrition = recipe.nutrition['nutrients']
            ?.where((nutrient) => importantNutrients.contains(nutrient['name']))
            ?.map((nutrient) => "${nutrient['name']}: ${nutrient['amount']}")
            ?.toList();

        return Scaffold(
          appBar: AppBar(title: Text(recipe.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(recipe.image, fit: BoxFit.cover),
                SizedBox(height: 16),
                Text(recipe.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text("Cuisines: $cuisines"),
                SizedBox(height: 8),
                Text("Ready in ${recipe.readyInMinutes ?? 'N/A'} minutes"),
                SizedBox(height: 16),
                Text("Ingredients:", style: TextStyle(fontSize: 18)),
                ...recipe.ingredients.map((ingredient) => Text("- $ingredient")).toList(),
                SizedBox(height: 16),
                Text("Instructions:", style: TextStyle(fontSize: 18)),
                Text(recipe.instructions),
                SizedBox(height: 16),
                Text("Nutrition Info:", style: TextStyle(fontSize: 18)),
                if (filteredNutrition != null)
                  ...filteredNutrition.map((info) => Text(info)).toList()
                else
                  Text("No nutrition information available."),
                SizedBox(height: 16),
                Divider(thickness: 2),
                Center(
                  child: FavoriteButton(recipeId: recipe.id),
                ),
                Divider(thickness: 2),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a Comment',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write your comment here',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<double>(
                            value: _rating,
                            onChanged: (value) {
                              _rating = value!;
                            },
                            items: List.generate(
                              5,
                              (index) => DropdownMenuItem(
                                value: (index + 1).toDouble(),
                                child: Text('${index + 1} Stars'),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please log in to add comments.')),
                                );
                                return;
                              }

                              await _firebaseService.addComment(
                                recipe.id.toString(),
                                user.uid,
                                _rating,
                                _commentController.text,
                              );

                              _commentController.clear();
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _firebaseService.getComments(recipe.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No comments available.'));
                    }

                    final commentsData = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: commentsData.length,
                      itemBuilder: (context, index) {
                        final comment = commentsData[index];
                        return ListTile(
                          title: Text('${comment['username']}'),
                          subtitle: Text('${comment['comment']}'),
                          trailing: Text('${comment['rating']} Stars'),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final int recipeId;
  FavoriteButton({required this.recipeId});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final userId = _auth.currentUser!.uid;
    final userFavoritesDoc = await _firestore.collection('usersfavorites').doc(userId).get();

    if (userFavoritesDoc.exists) {
      final List<String> favorites = List<String>.from(userFavoritesDoc.data()!['favorites'] ?? []);
      setState(() {
        isFavorite = favorites.contains(widget.recipeId.toString());
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = _auth.currentUser!.uid;
    final userFavoritesRef = _firestore.collection('usersfavorites').doc(userId);

    try {
      final userFavoritesDoc = await userFavoritesRef.get();

      if (userFavoritesDoc.exists) {
        final List<String> favorites = List<String>.from(userFavoritesDoc.data()!['favorites'] ?? []);

        if (isFavorite) {
          favorites.remove(widget.recipeId.toString());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from favorites.')));
        } else {
          favorites.add(widget.recipeId.toString());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to favorites.')));
        }

        await userFavoritesRef.update({'favorites': favorites});
      } else {
        await userFavoritesRef.set({
          'favorites': [widget.recipeId.toString()],
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to favorites.')));
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
