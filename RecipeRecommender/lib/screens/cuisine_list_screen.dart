import 'package:flutter/material.dart';
import '/screens/cuisine_recipes_screen.dart';
class CuisineListScreen extends StatelessWidget {
  final List<String> cuisines = ["Asian", "Arabic", "Italian", "Mexican", "French"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cuisines"),
      ),
      body: ListView.builder(
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cuisines[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CuisineRecipesScreen(cuisine: cuisines[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}