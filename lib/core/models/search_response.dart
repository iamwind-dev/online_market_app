/// Model cho search response
class SearchResponse {
  final bool success;
  final SearchData data;

  SearchResponse({
    required this.success,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      success: json['success'] as bool,
      data: SearchData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SearchData {
  final List<SearchStall> stalls;
  final List<SearchDish> dishes;
  final List<SearchIngredient> ingredients;

  SearchData({
    required this.stalls,
    required this.dishes,
    required this.ingredients,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      stalls: (json['stalls'] as List?)
              ?.map((item) => SearchStall.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      dishes: (json['dishes'] as List?)
              ?.map((item) => SearchDish.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      ingredients: (json['ingredients'] as List?)
              ?.map((item) => SearchIngredient.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isEmpty => stalls.isEmpty && dishes.isEmpty && ingredients.isEmpty;
  int get totalResults => stalls.length + dishes.length + ingredients.length;
}

class SearchStall {
  final String id;
  final String name;
  final String type;
  final String? image;

  SearchStall({
    required this.id,
    required this.name,
    required this.type,
    this.image,
  });

  factory SearchStall.fromJson(Map<String, dynamic> json) {
    return SearchStall(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
    );
  }
}

class SearchDish {
  final String id;
  final String name;
  final String type;
  final String? image;

  SearchDish({
    required this.id,
    required this.name,
    required this.type,
    this.image,
  });

  factory SearchDish.fromJson(Map<String, dynamic> json) {
    return SearchDish(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
    );
  }
}

class SearchIngredient {
  final String id;
  final String name;
  final String type;
  final String? image;

  SearchIngredient({
    required this.id,
    required this.name,
    required this.type,
    this.image,
  });

  factory SearchIngredient.fromJson(Map<String, dynamic> json) {
    return SearchIngredient(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
    );
  }
}
