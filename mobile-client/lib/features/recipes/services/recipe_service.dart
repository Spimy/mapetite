import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import '../models/recipe_model.dart';

class RecipeService {
  Future<List<RecipeModel>> getRecipes({
    String? query,
    int? currentUserId,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.recipes,
      params: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => RecipeModel.fromJson(
                json,
                currentUserId: currentUserId,
              ))
          .toList();
    }

    return [];
  }

  Future<RecipeModel> getRecipeById(
    String id, {
    int? currentUserId,
  }) async {
    final response = await ApiClient.get(ApiEndpoints.recipe(id));

    return RecipeModel.fromJson(
      response.data as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }

  Future<RecipeModel> createRecipe(
    RecipeModel recipe, {
    int? currentUserId,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.recipes,
      data: recipe.toRequestJson(),
    );

    return RecipeModel.fromJson(
      response.data as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }

  Future<RecipeModel> updateRecipe(
    RecipeModel recipe, {
    int? currentUserId,
  }) async {
    final response = await ApiClient.put(
      ApiEndpoints.recipe(recipe.id),
      data: recipe.toRequestJson(),
    );

    return RecipeModel.fromJson(
      response.data as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }

  Future<void> deleteRecipe(String id) async {
    await ApiClient.delete(ApiEndpoints.recipe(id));
  }

  Future<RecipeModel> saveRecipe(
    String id, {
    int? currentUserId,
  }) async {
    final response = await ApiClient.post(ApiEndpoints.recipeSave(id));

    return RecipeModel.fromJson(
      response.data as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }

  Future<RecipeModel> unsaveRecipe(
    String id, {
    int? currentUserId,
  }) async {
    final response = await ApiClient.delete(ApiEndpoints.recipeSave(id));

    return RecipeModel.fromJson(
      response.data as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }
}