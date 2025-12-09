import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'productdetail_state.dart';
import '../../../../../core/services/mon_an_service.dart';
import '../../../../../core/services/nguyen_lieu_service.dart';
import '../../../../../core/services/cart_api_service.dart';
import '../../../../../core/dependency/injection.dart';

/// Cubit quản lý state cho ProductDetail
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final MonAnService _monAnService = getIt<MonAnService>();
  final NguyenLieuService _nguyenLieuService = getIt<NguyenLieuService>();
  final CartApiService _cartApiService = getIt<CartApiService>();

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
        // Parse gian hàng
        final gianHangList = nl.gianHang?.map((gh) {
          return GianHangSimple(
            maGianHang: gh.maGianHang,
            tenGianHang: gh.tenGianHang,
            maCho: gh.maCho,
          );
        }).toList();
        
        return NguyenLieuInfo(
          maNguyenLieu: nl.maNguyenLieu,
          ten: nl.tenNguyenLieu ?? 'N/A',
          dinhLuong: nl.dinhLuong ?? '',
          donVi: nl.donViGoc,
          hinhAnh: nl.hinhAnh,
          gia: nl.gia,
          donViBan: nl.donViBan,
          gianHang: gianHangList,
        );
      }).toList();
      
      // Chuyển đổi danh mục từ model sang state info
      final danhMucList = detail.danhMuc?.map((dm) {
        return DanhMucInfo(ten: dm.tenDanhMuc ?? 'N/A');
      }).toList();
      
      // Cập nhật state với thông tin từ API
      emit(state.copyWith(
        maMonAn: maMonAn, // Lưu mã món ăn để reload sau
        productName: detail.tenMonAn,
        productImage: detail.hinhAnh.isNotEmpty 
            ? detail.hinhAnh 
            : 'assets/img/productdetail_main_image.png',
        doKho: detail.doKho,
        khoangThoiGian: detail.khoangThoiGian,
        khauPhanTieuChuan: detail.khauPhanTieuChuan,
        currentKhauPhan: detail.khauPhanHienTai ?? detail.khauPhanTieuChuan ?? 1,
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
      
      // Fetch giá nguyên liệu từ API chi tiết nguyên liệu
      if (nguyenLieuList != null && nguyenLieuList.isNotEmpty) {
        _fetchIngredientPrices(nguyenLieuList);
      }
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

  /// Thêm tất cả nguyên liệu vào giỏ hàng
  /// Trả về số nguyên liệu thêm thành công và danh sách lỗi
  Future<AddAllResult> addAllIngredientsToCart() async {
    final nguyenLieuList = state.nguyenLieu;
    
    debugPrint('🛒 [ADD ALL] Bắt đầu thêm tất cả nguyên liệu vào giỏ hàng');
    debugPrint('🛒 [ADD ALL] Số nguyên liệu: ${nguyenLieuList?.length ?? 0}');
    
    if (nguyenLieuList == null || nguyenLieuList.isEmpty) {
      debugPrint('🛒 [ADD ALL] Không có nguyên liệu');
      return AddAllResult(success: 0, failed: 0, errors: ['Không có nguyên liệu']);
    }

    int successCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    for (final nl in nguyenLieuList) {
      debugPrint('🛒 [ADD ALL] Xử lý: ${nl.ten}');
      debugPrint('   - maNguyenLieu: ${nl.maNguyenLieu}');
      debugPrint('   - dinhLuong: ${nl.dinhLuong}');
      debugPrint('   - gianHang: ${nl.gianHang?.length ?? 0} gian hàng');
      
      // Bỏ qua nếu không có mã nguyên liệu hoặc gian hàng
      if (nl.maNguyenLieu == null || nl.maNguyenLieu!.isEmpty) {
        failedCount++;
        errors.add('${nl.ten}: Không có mã nguyên liệu');
        debugPrint('   ❌ Không có mã nguyên liệu');
        continue;
      }

      if (nl.gianHang == null || nl.gianHang!.isEmpty) {
        failedCount++;
        errors.add('${nl.ten}: Không có gian hàng');
        debugPrint('   ❌ Không có gian hàng');
        continue;
      }

      // Lấy gian hàng đầu tiên
      final gianHang = nl.gianHang!.first;
      debugPrint('   - maGianHang: ${gianHang.maGianHang}');
      debugPrint('   - maCho: ${gianHang.maCho}');
      
      if (gianHang.maGianHang == null || gianHang.maGianHang!.isEmpty) {
        failedCount++;
        errors.add('${nl.ten}: Không có mã gian hàng');
        debugPrint('   ❌ Không có mã gian hàng');
        continue;
      }

      // Parse số lượng từ định lượng
      final soLuong = _parseSoLuong(nl.dinhLuong);
      debugPrint('   - soLuong (parsed): $soLuong');

      try {
        await _cartApiService.addToCart(
          maNguyenLieu: nl.maNguyenLieu!,
          maGianHang: gianHang.maGianHang!,
          soLuong: soLuong,
          maCho: gianHang.maCho ?? 'C01',
        );
        successCount++;
        debugPrint('   ✅ Đã thêm ${nl.ten} vào giỏ hàng');
      } catch (e) {
        failedCount++;
        errors.add('${nl.ten}: $e');
        debugPrint('   ❌ Lỗi thêm ${nl.ten}: $e');
      }
    }

    debugPrint('🛒 [ADD ALL] Kết quả: $successCount thành công, $failedCount thất bại');
    if (errors.isNotEmpty) {
      debugPrint('🛒 [ADD ALL] Lỗi: $errors');
    }

    return AddAllResult(
      success: successCount,
      failed: failedCount,
      errors: errors,
    );
  }

  /// Parse số lượng từ định lượng
  /// VD: "200g" -> 200, "100" -> 100, "1.5kg" -> 1.5, "0.5" -> 0.5
  double _parseSoLuong(String dinhLuong) {
    if (dinhLuong.isEmpty) return 1;
    
    // Loại bỏ ký tự đặc biệt như \r, \n, khoảng trắng
    final cleaned = dinhLuong.replaceAll(RegExp(r'[\r\n\s]'), '');
    
    // Tìm số trong chuỗi (hỗ trợ số thập phân)
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(cleaned);
    
    if (match != null) {
      final number = double.tryParse(match.group(1) ?? '');
      if (number != null && number > 0) {
        return number;
      }
    }
    
    // Mặc định là 1
    return 1;
  }

  /// Tăng khẩu phần và reload dữ liệu
  Future<void> increaseKhauPhan() async {
    final newKhauPhan = state.currentKhauPhan + 1;
    emit(state.copyWith(currentKhauPhan: newKhauPhan));
    
    // Reload dữ liệu với khẩu phần mới
    if (state.productName.isNotEmpty) {
      await _reloadWithKhauPhan(newKhauPhan);
    }
  }

  /// Giảm khẩu phần (tối thiểu là 1) và reload dữ liệu
  Future<void> decreaseKhauPhan() async {
    if (state.currentKhauPhan > 1) {
      final newKhauPhan = state.currentKhauPhan - 1;
      emit(state.copyWith(currentKhauPhan: newKhauPhan));
      
      // Reload dữ liệu với khẩu phần mới
      if (state.productName.isNotEmpty) {
        await _reloadWithKhauPhan(newKhauPhan);
      }
    }
  }

  /// Fetch giá nguyên liệu từ API chi tiết nguyên liệu
  Future<void> _fetchIngredientPrices(List<NguyenLieuInfo> nguyenLieuList) async {
    try {
      // Lọc các nguyên liệu có mã
      final ingredientsWithCode = nguyenLieuList
          .where((nl) => nl.maNguyenLieu != null && nl.maNguyenLieu!.isNotEmpty)
          .toList();
      
      if (ingredientsWithCode.isEmpty) return;
      
      // Fetch giá song song cho tất cả nguyên liệu
      final futures = ingredientsWithCode.map((nl) async {
        try {
          final detail = await _nguyenLieuService.getNguyenLieuDetail(nl.maNguyenLieu!);
          return MapEntry(nl.maNguyenLieu!, detail);
        } catch (e) {
          debugPrint('Lỗi fetch giá nguyên liệu ${nl.maNguyenLieu}: $e');
          return null;
        }
      });
      
      final results = await Future.wait(futures);
      
      if (isClosed) return;
      
      // Tạo map giá từ kết quả
      final priceMap = <String, double?>{};
      final donViBanMap = <String, String?>{};
      
      for (final result in results) {
        if (result != null) {
          final maNguyenLieu = result.key;
          final detail = result.value;
          // Ưu tiên giaCuoi, nếu không có thì dùng giaGoc
          final gia = detail.detail.giaCuoi != null 
              ? double.tryParse(detail.detail.giaCuoi!) 
              : detail.detail.giaGoc;
          priceMap[maNguyenLieu] = gia;
          donViBanMap[maNguyenLieu] = detail.detail.donVi;
        }
      }
      
      // Cập nhật state với giá mới (giữ lại gianHang)
      final updatedList = nguyenLieuList.map((nl) {
        if (nl.maNguyenLieu != null && priceMap.containsKey(nl.maNguyenLieu)) {
          return NguyenLieuInfo(
            maNguyenLieu: nl.maNguyenLieu,
            ten: nl.ten,
            dinhLuong: nl.dinhLuong,
            donVi: nl.donVi,
            hinhAnh: nl.hinhAnh,
            gia: priceMap[nl.maNguyenLieu],
            donViBan: donViBanMap[nl.maNguyenLieu] ?? nl.donViBan,
            gianHang: nl.gianHang, // Giữ lại gianHang
          );
        }
        return nl;
      }).toList();
      
      emit(state.copyWith(nguyenLieu: updatedList));
    } catch (e) {
      debugPrint('Lỗi fetch giá nguyên liệu: $e');
    }
  }

  /// Reload dữ liệu món ăn với khẩu phần mới
  Future<void> _reloadWithKhauPhan(int khauPhan) async {
    try {
      // Lấy mã món ăn từ state (cần lưu trong state)
      final maMonAn = state.maMonAn;
      if (maMonAn == null || maMonAn.isEmpty) return;

      // Gọi API với parameter khau_phan
      final detail = await _monAnService.getMonAnDetail(maMonAn, khauPhan: khauPhan);
      
      if (isClosed) return;
      
      // Chuyển đổi nguyên liệu từ model sang state info (reload)
      final nguyenLieuList = detail.nguyenLieu?.map((nl) {
        final gianHangList = nl.gianHang?.map((gh) {
          return GianHangSimple(
            maGianHang: gh.maGianHang,
            tenGianHang: gh.tenGianHang,
            maCho: gh.maCho,
          );
        }).toList();
        
        return NguyenLieuInfo(
          maNguyenLieu: nl.maNguyenLieu,
          ten: nl.tenNguyenLieu ?? 'N/A',
          dinhLuong: nl.dinhLuong ?? '',
          donVi: nl.donViGoc,
          hinhAnh: nl.hinhAnh,
          gia: nl.gia,
          donViBan: nl.donViBan,
          gianHang: gianHangList,
        );
      }).toList();
      
      // Cập nhật state với thông tin mới
      emit(state.copyWith(
        nguyenLieu: nguyenLieuList,
        calories: detail.caloriesTongTheoKhauPhan ?? detail.calories,
      ));
      
      // Fetch giá nguyên liệu
      if (nguyenLieuList != null && nguyenLieuList.isNotEmpty) {
        _fetchIngredientPrices(nguyenLieuList);
      }
    } catch (e) {
      // Không hiển thị lỗi khi reload, chỉ log
      debugPrint('Lỗi khi reload với khẩu phần mới: $e');
    }
  }
}
