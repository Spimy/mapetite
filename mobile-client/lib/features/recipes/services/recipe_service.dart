import '../models/recipe_model.dart';
import '../models/mocks/recipe_mocks.dart';

class RecipeService {
  Future<List<RecipeModel>> getRecipes() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return RecipeMocks.recipes;
    // TODO: Replace with real API call to GET /api/v1/recipes/
  }

  Future<RecipeModel?> getRecipeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return RecipeMocks.recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
    // TODO: Replace with real API call to GET /api/v1/recipes/:id
  }

  Future<RecipeModel> createRecipe(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return RecipeMocks.recipes.first;
    // TODO: Replace with real API call to POST /api/v1/recipes/
  }
}
