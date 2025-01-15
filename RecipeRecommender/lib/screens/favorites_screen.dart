import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final userId = _auth.currentUser!.uid;
      final favoritesSnapshot = await _firestore
          .collection('usersfavorites')
          .doc(userId)
          .get();

      if (favoritesSnapshot.exists) {
        final List<String> recipeIds = List<String>.from(favoritesSnapshot.data()!['favorites'] ?? []);
        
        for (String recipeId in recipeIds) {
          final recipeDetails = await ApiService().fetchRecipeDetails(int.parse(recipeId));
          favoriteRecipes.add(recipeDetails);
        }
      }
    } catch (error) {
      print('Error fetching favorites: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteRecipes.isEmpty
              ? Center(child: Text('No favorites found.'))
              : ListView.builder(
                  itemCount: favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = favoriteRecipes[index];
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
    );
  }
}
