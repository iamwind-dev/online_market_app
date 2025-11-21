import 'package:equatable/equatable.dart';

/// State cho IngredientDetail
class IngredientDetailState extends Equatable {
  final String? maNguyenLieu;
  final String ingredientName;
  final String ingredientImage;
  final String price;
  final String unit;
  final double rating;
  final int soldCount;
  final String shopName;
  final String description;
  final List<Seller> sellers; // Danh sách người bán
  final Seller? selectedSeller; // Gian hàng được chọn
  final int quantity; // Số lượng muốn mua
  final List<RelatedProduct> relatedProducts;
  final List<RelatedProduct> recommendedProducts;
  final int cartItemCount;
  final bool isFavorite;
  final bool isLoading;
  final String? errorMessage;

  const IngredientDetailState({
    this.maNguyenLieu,
    this.ingredientName = '',
    this.ingredientImage = '',
    this.price = '',
    this.unit = 'Ký',
    this.rating = 0.0,
    this.soldCount = 0,
    this.shopName = '',
    this.description = '',
    this.sellers = const [],
    this.selectedSeller,
    this.quantity = 1,
    this.relatedProducts = const [],
    this.recommendedProducts = const [],
    this.cartItemCount = 0,
    this.isFavorite = false,
    this.isLoading = false,
    this.errorMessage,
  });

  IngredientDetailState copyWith({
    String? maNguyenLieu,
    String? ingredientName,
    String? ingredientImage,
    String? price,
    String? unit,
    double? rating,
    int? soldCount,
    String? shopName,
    String? description,
    List<Seller>? sellers,
    Object? selectedSeller = _undefined, // Sử dụng sentinel value
    int? quantity,
    List<RelatedProduct>? relatedProducts,
    List<RelatedProduct>? recommendedProducts,
    int? cartItemCount,
    bool? isFavorite,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IngredientDetailState(
      maNguyenLieu: maNguyenLieu ?? this.maNguyenLieu,
      ingredientName: ingredientName ?? this.ingredientName,
      ingredientImage: ingredientImage ?? this.ingredientImage,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      rating: rating ?? this.rating,
      soldCount: soldCount ?? this.soldCount,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      sellers: sellers ?? this.sellers,
      selectedSeller: selectedSeller == _undefined 
          ? this.selectedSeller 
          : selectedSeller as Seller?,
      quantity: quantity ?? this.quantity,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        maNguyenLieu,
        ingredientName,
        ingredientImage,
        price,
        unit,
        rating,
        soldCount,
        shopName,
        description,
        sellers,
        selectedSeller,
        quantity,
        relatedProducts,
        recommendedProducts,
        cartItemCount,
        isFavorite,
        isLoading,
        errorMessage,
      ];
}

// Sentinel value để phân biệt "không truyền" vs "truyền null"
const _undefined = Object();

/// Model cho người bán (seller) trong state
class Seller extends Equatable {
  final String maGianHang;
  final String tenGianHang;
  final String viTri;
  final String price;
  final String? originalPrice;
  final bool hasDiscount;
  final String? imagePath;
  final int soldCount;
  final String? unit;

  const Seller({
    required this.maGianHang,
    required this.tenGianHang,
    required this.viTri,
    required this.price,
    this.originalPrice,
    this.hasDiscount = false,
    this.imagePath,
    required this.soldCount,
    this.unit,
  });

  @override
  List<Object?> get props => [
        maGianHang,
        tenGianHang,
        viTri,
        price,
        originalPrice,
        hasDiscount,
        imagePath,
        soldCount,
        unit,
      ];
}

/// Model cho sản phẩm liên quan
class RelatedProduct extends Equatable {
  final String name;
  final String price;
  final String imagePath;
  final String shopName;
  final int soldCount;

  const RelatedProduct({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.shopName,
    required this.soldCount,
  });

  @override
  List<Object?> get props => [name, price, imagePath, shopName, soldCount];
}
