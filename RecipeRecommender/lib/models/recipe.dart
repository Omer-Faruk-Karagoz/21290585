class Recipe {
  final int id;
  final String title;
  final String image;
  final int? readyInMinutes;
  final List<String> cuisines;
  final List<String> ingredients;
  final String instructions;
  final Map<String, dynamic> nutrition;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    this.readyInMinutes,
    required this.cuisines,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? "Unknown",
      image: json['image'] ?? "",
      readyInMinutes: json['readyInMinutes'],
      cuisines: List<String>.from(json['cuisines'] ?? []),
      ingredients: (json['extendedIngredients'] ?? [])
          .map<String>((ingredient) => ingredient['original']?.toString() ?? "")
          .toList(),
      instructions: json['instructions'] ?? "No instructions available.",
      nutrition: json['nutrition'] ?? {},
    );
  }
}
