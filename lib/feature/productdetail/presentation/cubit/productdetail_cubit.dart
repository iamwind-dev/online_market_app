import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:DNGO/feature/productdetail/presentation/cubit/productdetail_state.dart';
import 'package:DNGO/core/services/mon_an_service.dart';
import 'package:DNGO/core/dependency/injection.dart';

/// Cubit quản lý state cho ProductDetail
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final MonAnService _monAnService = getIt<MonAnService>();

  ProductDetailCubit() : super(const ProductDetailState());

  /// Load thông tin chi tiết món ăn từ API
  /// 
  /// [maMonAn] - Mã món ăn từ ProductScreen (bắt buộc)
  /// 
  /// Gọi API: GET /api/buyer/mon-an/{ma_mon_an}
  /// Response: { "success": true, "detail": {...} }
  Future<void> loadProductDetails(String maMonAn) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Gọi API để lấy chi tiết món ăn
      final detail = await _monAnService.getMonAnDetail(maMonAn);
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      // Chuyển đổi nguyên liệu từ model sang state info
      final nguyenLieuList = detail.nguyenLieu?.map((nl) {
        return NguyenLieuInfo(
          ten: nl.tenNguyenLieu ?? 'N/A',
          dinhLuong: nl.dinhLuong ?? '',
          donVi: nl.donViGoc,
        );
      }).toList();
      
      // Chuyển đổi danh mục từ model sang state info
      final danhMucList = detail.danhMuc?.map((dm) {
        return DanhMucInfo(ten: dm.tenDanhMuc ?? 'N/A');
      }).toList();
      
      // Cập nhật state với thông tin từ API
      emit(state.copyWith(
        productName: detail.tenMonAn,
        productImage: detail.hinhAnh.isNotEmpty 
            ? detail.hinhAnh 
            : 'assets/img/productdetail_main_image.png',
        doKho: detail.doKho,
        khoangThoiGian: detail.khoangThoiGian,
        khauPhanTieuChuan: detail.khauPhanTieuChuan,
        calories: detail.calories,
        cachThucHien: detail.cachThucHien,
        soChe: detail.soChe,
        cachDung: detail.cachDung,
        nguyenLieu: nguyenLieuList,
        danhMuc: danhMucList,
        category: danhMucList?.first.ten ?? 'Chưa phân loại',
        shopName: 'Công thức món ăn',
        rating: 4.5,
        soldCount: detail.soNguyenLieu ?? 0,
        price: detail.calories?.toString() ?? 'N/A',
        priceUnit: 'Cal',
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      // Nếu lỗi, hiển thị thông báo lỗi
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi khi tải thông tin món ăn: $e',
        ));
      }
    }
  }

  /// Toggle favorite status
  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }

  /// Add to cart
  void addToCart() {
    emit(state.copyWith(cartItemCount: state.cartItemCount + 1));
  }

  /// Update cart item count
  void updateCartItemCount(int count) {
    emit(state.copyWith(cartItemCount: count));
  }

  /// Buy now action
  void buyNow() {
    // Implement buy now logic
    addToCart();
  }

  /// Chat with shop
  void chatWithShop() {
    // Implement chat logic
  }
}
