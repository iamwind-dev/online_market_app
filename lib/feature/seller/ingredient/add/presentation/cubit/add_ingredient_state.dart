import 'package:equatable/equatable.dart';

/// Model đại diện cho danh mục sản phẩm
class Category extends Equatable {
  final String id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

/// State chính của Add Ingredient
class AddIngredientState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  // Form fields
  final String productName;
  final String? imagePath;
  final Category? selectedCategory;
  final List<Category> categories;

  // Validation
  final bool isFormValid;
  final int currentTabIndex;

  const AddIngredientState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.productName = '',
    this.imagePath,
    this.selectedCategory,
    this.categories = const [],
    this.isFormValid = false,
    this.currentTabIndex = 1,
  });

  /// Factory tạo state ban đầu
  factory AddIngredientState.initial() {
    return const AddIngredientState(isLoading: true);
  }

  /// Kiểm tra form hợp lệ
  bool get canSubmit {
    return productName.length >= 15 &&
        imagePath != null &&
        selectedCategory != null;
  }

  AddIngredientState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    String? productName,
    String? imagePath,
    Category? selectedCategory,
    List<Category>? categories,
    bool? isFormValid,
    int? currentTabIndex,
  }) {
    return AddIngredientState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      productName: productName ?? this.productName,
      imagePath: imagePath ?? this.imagePath,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      isFormValid: isFormValid ?? this.isFormValid,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
        productName,
        imagePath,
        selectedCategory,
        categories,
        isFormValid,
        currentTabIndex,
      ];
}
