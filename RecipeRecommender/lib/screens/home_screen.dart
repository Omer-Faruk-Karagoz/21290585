// home_screen.dart
import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'cuisine_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recipes');
              },
              child: Text("Recipes"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/canI');
              },
              child: Text("Can I?"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/compare');
              },
              child: Text("Compare"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CuisineListScreen()),
                );
              },
              child: Text("Cuisines"),
            ),
          ],
        ),
      ),
    );
  }
}