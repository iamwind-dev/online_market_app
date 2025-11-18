import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_market_app/core/dependency/injection.dart';
import 'package:online_market_app/core/services/mon_an_service.dart';
import 'package:online_market_app/core/services/auth/auth_service.dart';
import 'package:online_market_app/core/error/exceptions.dart';
import 'package:online_market_app/core/models/mon_an_model.dart';
import 'category_product_state.dart';
import 'product_state.dart';

class CategoryProductCubit extends Cubit<CategoryProductState> {
  final MonAnService _monAnService = getIt<MonAnService>();
  String? _currentCategoryId;

  CategoryProductCubit() : super(CategoryProductInitial());

  /// Load món ăn theo danh mục
  Future<void> loadCategoryProducts({required String categoryId}) async {
    _currentCategoryId = categoryId;
    emit(CategoryProductLoading());

    try {
      // Debug: Print API call info
      print('═' * 80);
      print('📡 [API] Gọi API lấy danh sách món ăn theo danh mục');
      print('   Mã danh mục: $categoryId');
      print('   URL đầy đủ: https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer/mon-an?ma_danh_muc_mon_an=$categoryId&page=1&limit=12&sort=ten_mon_an&order=asc');
      print('═' * 80);
      
      // Fetch danh sách món ăn theo danh mục từ API (với metadata)
      final response = await _monAnService.getMonAnListWithMeta(
        page: 1,
        limit: 12,
        maDanhMuc: categoryId,
        sort: 'ten_mon_an',
        order: 'asc',
      );

      print('✅ [API] Nhận được ${response.data.length} món ăn từ API');
      print('   Tổng số món trong danh mục: ${response.meta.total}');
      print('   Trang: ${response.meta.page}/${(response.meta.total / response.meta.limit).ceil()}');

      if (isClosed) return;

      // Fetch chi tiết (ảnh, thời gian, độ khó, khẩu phần) cho từng món ăn
      print('🖼️ [API] Đang fetch chi tiết (ảnh, thời gian, độ khó) cho ${response.data.length} món ăn...');
      final monAnWithImages = await _fetchMonAnImages(response.data);

      print('✅ [API] Đã fetch chi tiết cho tất cả ${monAnWithImages.length} món ăn');

      if (isClosed) return;

      emit(CategoryProductLoaded(
        monAnList: monAnWithImages,
        currentPage: 1,
        hasMore: response.meta.hasNext,
        totalItems: response.meta.total,
      ));
      
      print('✅ [STATE] Emit CategoryProductLoaded với ${monAnWithImages.length} món ăn (tổng: ${response.meta.total})');
    } on UnauthorizedException {
      final authService = getIt<AuthService>();
      await authService.logout();
      if (!isClosed) {
        emit(const CategoryProductError(
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          requiresLogin: true,
        ));
      }
    } catch (e) {
      print('❌ [ERROR] Lỗi khi tải dữ liệu: $e');
      if (!isClosed) {
        emit(CategoryProductError('Lỗi khi tải dữ liệu: $e'));
      }
    }
  }

  /// Load thêm món ăn (pagination)
  Future<void> loadMoreProducts() async {
    if (state is! CategoryProductLoaded) return;
    if (_currentCategoryId == null) return;

    final currentState = state as CategoryProductLoaded;

    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      print('═' * 80);
      print('📡 [API] Load thêm trang $nextPage');
      print('   Mã danh mục: $_currentCategoryId');
      print('   URL đầy đủ: https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer/mon-an?ma_danh_muc_mon_an=$_currentCategoryId&page=$nextPage&limit=12&sort=ten_mon_an&order=asc');
      print('═' * 80);
      
      final response = await _monAnService.getMonAnListWithMeta(
        page: nextPage,
        limit: 12,
        maDanhMuc: _currentCategoryId,
        sort: 'ten_mon_an',
        order: 'asc',
      );

      print('✅ [API] Nhận được ${response.data.length} món ăn từ trang $nextPage');

      if (isClosed) return;

      final newMonAnWithImages = await _fetchMonAnImages(response.data);

      if (isClosed) return;

      final updatedList = [...currentState.monAnList, ...newMonAnWithImages];

      emit(currentState.copyWith(
        monAnList: updatedList,
        currentPage: nextPage,
        hasMore: response.meta.hasNext,
        isLoadingMore: false,
      ));
      
      print('✅ [STATE] Emit CategoryProductLoaded với ${updatedList.length} món ăn (trang $nextPage)');
    } catch (e) {
      if (!isClosed && state is CategoryProductLoaded) {
        emit((state as CategoryProductLoaded).copyWith(isLoadingMore: false));
      }
      print('❌ [ERROR] Lỗi khi load thêm món ăn: $e');
    }
  }

  /// Fetch chi tiết cho danh sách món ăn
  Future<List<MonAnWithImage>> _fetchMonAnImages(
      List<MonAnModel> monAnList) async {
    final result = <MonAnWithImage>[];

    for (int i = 0; i < monAnList.length; i++) {
      final monAn = monAnList[i];
      try {
        print('   [${i + 1}/${monAnList.length}] Fetch chi tiết: ${monAn.maMonAn} - ${monAn.tenMonAn}');
        final detail = await _monAnService.getMonAnDetail(monAn.maMonAn);
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: detail.hinhAnh,
          cookTime: detail.khoangThoiGian,
          difficulty: detail.doKho,
          servings: detail.khauPhanTieuChuan,
        ));
      } catch (e) {
        print('❌ [ERROR] Lỗi khi lấy chi tiết cho món ${monAn.maMonAn}: $e');
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: '',
        ));
      }
    }

    return result;
  }
}
