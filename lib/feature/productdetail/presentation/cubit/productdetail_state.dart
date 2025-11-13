import 'package:equatable/equatable.dart';

/// State cho ProductDetail
class ProductDetailState extends Equatable {
  final String productName;
  final String productImage;
  final String price;
  final String priceUnit;
  final double rating;
  final int soldCount;
  final String shopName;
  final String category;
  final String description;
  final List<Review> reviews;
  final int cartItemCount;
  final bool isFavorite;
  final bool isLoading;
  final String? errorMessage;

  const ProductDetailState({
    this.productName = '',
    this.productImage = '',
    this.price = '',
    this.priceUnit = '',
    this.rating = 0.0,
    this.soldCount = 0,
    this.shopName = '',
    this.category = '',
    this.description = '',
    this.reviews = const [],
    this.cartItemCount = 0,
    this.isFavorite = false,
    this.isLoading = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    String? productName,
    String? productImage,
    String? price,
    String? priceUnit,
    double? rating,
    int? soldCount,
    String? shopName,
    String? category,
    String? description,
    List<Review>? reviews,
    int? cartItemCount,
    bool? isFavorite,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductDetailState(
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      rating: rating ?? this.rating,
      soldCount: soldCount ?? this.soldCount,
      shopName: shopName ?? this.shopName,
      category: category ?? this.category,
      description: description ?? this.description,
      reviews: reviews ?? this.reviews,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        productName,
        productImage,
        price,
        priceUnit,
        rating,
        soldCount,
        shopName,
        category,
        description,
        reviews,
        cartItemCount,
        isFavorite,
        isLoading,
        errorMessage,
      ];
}

/// Model cho Review
class Review extends Equatable {
  final int stars;
  final int count;
  final double percentage;

  const Review({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [stars, count, percentage];
}
