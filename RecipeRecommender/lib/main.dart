import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/can_i_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/recipes': (context) => RecipesScreen(),
        '/recipeDetail': (context) => RecipeDetailScreen(),
        '/canI': (context) => CanIScreen(),
        '/compare': (context) => CompareScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/favorites': (context) => FavoritesScreen(),
      },
    );
  }
}
