import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mon_an_model.dart';
import '../models/mon_an_detail_model.dart';
import '../models/mon_an_response.dart';
import '../error/exceptions.dart';
import 'package:logger/logger.dart';

/// Service để gọi API món ăn
class MonAnService {
  static const String _baseUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';
  static const String _endpointList = '/mon-an';
  static const String _tokenKey = 'auth_token';

  final Dio _dio;
  final Logger _logger = Logger();

  MonAnService({Dio? dio}) : _dio = dio ?? Dio();

  /// Lấy danh sách món ăn từ API (trả về response với metadata)
  /// 
  /// [page] - Trang hiện tại (mặc định: 1)
  /// [limit] - Số lượng món ăn trên 1 trang (mặc định: 12)
  /// [maDanhMuc] - Mã danh mục để lọc (tùy chọn)
  /// [search] - Từ khóa tìm kiếm (tùy chọn)
  /// [sort] - Trường để sắp xếp (tùy chọn, vd: 'ten_mon_an')
  /// [order] - Thứ tự sắp xếp (tùy chọn, 'asc' hoặc 'desc')
  /// 
  /// Trả về: MonAnResponse - Danh sách món ăn + metadata (total, hasNext, etc)
  /// 
  /// Throws:
  /// - UnauthorizedException: Nếu token không hợp lệ hoặc hết hạn
  /// - NetworkException: Nếu có lỗi kết nối
  /// - ServerException: Nếu server trả về lỗi
  Future<MonAnResponse> getMonAnListWithMeta({
    int page = 1,
    int limit = 12,
    String? maDanhMuc,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      // 1. Lấy token từ SharedPreferences
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _logger.e('Token không tìm thấy');
        throw UnauthorizedException('Vui lòng đăng nhập lại');
      }

      // 2. Chuẩn bị headers với Bearer token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // 3. Chuẩn bị query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (maDanhMuc != null && maDanhMuc.isNotEmpty) {
        queryParams['ma_danh_muc_mon_an'] = maDanhMuc;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }
      if (order != null && order.isNotEmpty) {
        queryParams['order'] = order;
      }

      // 4. Gửi GET request
      final url = '$_baseUrl$_endpointList';
      _logger.i('Gọi API: GET $url?page=$page&limit=$limit');

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Timeout khi gọi API món ăn');
          throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
        },
      );

      // 5. Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 6. Parse response
        final data = response.data as Map<String, dynamic>;
        final monAnResponse = MonAnResponse.fromJson(data);

        _logger.i('API trả về ${monAnResponse.data.length} món ăn (trang ${monAnResponse.meta.page}/${(monAnResponse.meta.total / monAnResponse.meta.limit).ceil()})');

        return monAnResponse;
      } else if (response.statusCode == 401) {
        _logger.e('Token không hợp lệ hoặc hết hạn');
        throw UnauthorizedException('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else {
        _logger.e('Lỗi server: ${response.statusCode}');
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on UnauthorizedException {
      _logger.e('UnauthorizedException khi lấy danh sách món ăn');
      rethrow;
    } on NetworkException {
      _logger.e('NetworkException khi lấy danh sách món ăn');
      rethrow;
    } on ServerException {
      _logger.e('ServerException khi lấy danh sách món ăn');
      rethrow;
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
      } else if (e.type == DioExceptionType.unknown) {
        throw NetworkException('Lỗi kết nối mạng, vui lòng kiểm tra kết nối');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token không hợp lệ, vui lòng đăng nhập lại');
      } else {
        throw ServerException('Lỗi server: ${e.message}');
      }
    } catch (e) {
      _logger.e('Lỗi không xác định: $e');
      throw ServerException('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  /// Lấy danh sách món ăn từ API (chỉ trả về danh sách, không có metadata)
  /// 
  /// [page] - Trang hiện tại (mặc định: 1)
  /// [limit] - Số lượng món ăn trên 1 trang (mặc định: 12)
  /// [maDanhMuc] - Mã danh mục để lọc (tùy chọn)
  /// [search] - Từ khóa tìm kiếm (tùy chọn)
  /// [sort] - Trường để sắp xếp (tùy chọn, vd: 'ten_mon_an')
  /// [order] - Thứ tự sắp xếp (tùy chọn, 'asc' hoặc 'desc')
  /// 
  /// Trả về: List<MonAnModel> - Danh sách món ăn
  /// 
  /// Throws:
  /// - UnauthorizedException: Nếu token không hợp lệ hoặc hết hạn
  /// - NetworkException: Nếu có lỗi kết nối
  /// - ServerException: Nếu server trả về lỗi
  Future<List<MonAnModel>> getMonAnList({
    int page = 1,
    int limit = 12,
    String? maDanhMuc,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      // 1. Lấy token từ SharedPreferences
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _logger.e('Token không tìm thấy');
        throw UnauthorizedException('Vui lòng đăng nhập lại');
      }

      // 2. Chuẩn bị headers với Bearer token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // 3. Chuẩn bị query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (maDanhMuc != null && maDanhMuc.isNotEmpty) {
        queryParams['ma_danh_muc_mon_an'] = maDanhMuc;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }
      if (order != null && order.isNotEmpty) {
        queryParams['order'] = order;
      }

      // 4. Gửi GET request
      final url = '$_baseUrl$_endpointList';
      _logger.i('Gọi API: GET $url?page=$page&limit=$limit');

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Timeout khi gọi API món ăn');
          throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
        },
      );

      // 5. Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 6. Parse response
        final data = response.data as Map<String, dynamic>;
        
        // 7. Lấy danh sách món ăn từ data
        final monAnJson = data['data'] as List<dynamic>? ?? [];
        final monAnList = monAnJson
            .map((item) => MonAnModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // 8. Lấy meta nếu cần
        if (data.containsKey('meta')) {
          final metaJson = data['meta'] as Map<String, dynamic>;
          final meta = MonAnMeta.fromJson(metaJson);
          _logger.i('API trả về ${monAnList.length} món ăn (trang ${meta.page}/${(meta.total / meta.limit).ceil()})');
        }

        return monAnList;
      } else if (response.statusCode == 401) {
        _logger.e('Token không hợp lệ hoặc hết hạn');
        throw UnauthorizedException('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else {
        _logger.e('Lỗi server: ${response.statusCode}');
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on UnauthorizedException {
      _logger.e('UnauthorizedException khi lấy danh sách món ăn');
      rethrow;
    } on NetworkException {
      _logger.e('NetworkException khi lấy danh sách món ăn');
      rethrow;
    } on ServerException {
      _logger.e('ServerException khi lấy danh sách món ăn');
      rethrow;
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      
      // Xử lý các lỗi cụ thể từ Dio
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
      } else if (e.type == DioExceptionType.unknown) {
        throw NetworkException('Lỗi kết nối mạng, vui lòng kiểm tra kết nối');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token không hợp lệ, vui lòng đăng nhập lại');
      } else {
        throw ServerException('Lỗi server: ${e.message}');
      }
    } catch (e) {
      _logger.e('Lỗi không xác định: $e');
      throw ServerException('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  /// Lấy chi tiết món ăn từ API (có ảnh)
  /// 
  /// [maMonAn] - Mã món ăn cần lấy chi tiết
  /// [khauPhan] - Số khẩu phần (tùy chọn, để tính toán lại định lượng nguyên liệu)
  /// 
  /// Trả về: MonAnDetailModel - Thông tin chi tiết món ăn bao gồm ảnh
  /// 
  /// Throws:
  /// - UnauthorizedException: Nếu token không hợp lệ hoặc hết hạn
  /// - NetworkException: Nếu có lỗi kết nối
  /// - ServerException: Nếu server trả về lỗi
  Future<MonAnDetailModel> getMonAnDetail(String maMonAn, {int? khauPhan}) async {
    try {
      // 1. Lấy token từ SharedPreferences
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _logger.e('Token không tìm thấy');
        throw UnauthorizedException('Vui lòng đăng nhập lại');
      }

      // 2. Chuẩn bị headers với Bearer token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // 3. Chuẩn bị query parameters
      final queryParams = <String, dynamic>{};
      if (khauPhan != null) {
        queryParams['khau_phan'] = khauPhan.toString();
      }

      // 4. Gửi GET request
      final url = '$_baseUrl$_endpointList/$maMonAn';
      _logger.i('Gọi API: GET $url${khauPhan != null ? '?khau_phan=$khauPhan' : ''}');

      final response = await _dio.get(
        url,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: headers),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Timeout khi gọi API chi tiết món ăn');
          throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
        },
      );

      // 4. Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 5. Parse response
        final data = response.data as Map<String, dynamic>;
        
        // Debug: In ra nguyên liệu để xem cấu trúc
        if (data['detail'] != null && data['detail']['nguyen_lieu'] != null) {
          final nguyenLieuList = data['detail']['nguyen_lieu'] as List<dynamic>;
          _logger.i('🔍 [DEBUG] Số nguyên liệu: ${nguyenLieuList.length}');
          for (var nl in nguyenLieuList) {
            _logger.i('🔍 [DEBUG] Nguyên liệu: $nl');
          }
        }
        
        final detail = MonAnDetailModel.fromJson(data);

        _logger.i('API trả về chi tiết món ăn: ${detail.tenMonAn}');
        _logger.i('URL ảnh: ${detail.hinhAnh}');

        return detail;
      } else if (response.statusCode == 401) {
        _logger.e('Token không hợp lệ hoặc hết hạn');
        throw UnauthorizedException('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else if (response.statusCode == 404) {
        _logger.e('Không tìm thấy món ăn: $maMonAn');
        throw ServerException('Không tìm thấy món ăn');
      } else {
        _logger.e('Lỗi server: ${response.statusCode}');
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on UnauthorizedException {
      _logger.e('UnauthorizedException khi lấy chi tiết món ăn');
      rethrow;
    } on NetworkException {
      _logger.e('NetworkException khi lấy chi tiết món ăn');
      rethrow;
    } on ServerException {
      _logger.e('ServerException khi lấy chi tiết món ăn');
      rethrow;
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      
      // Xử lý các lỗi cụ thể từ Dio
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
      } else if (e.type == DioExceptionType.unknown) {
        throw NetworkException('Lỗi kết nối mạng, vui lòng kiểm tra kết nối');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token không hợp lệ, vui lòng đăng nhập lại');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Không tìm thấy món ăn');
      } else {
        throw ServerException('Lỗi server: ${e.message}');
      }
    } catch (e) {
      _logger.e('Lỗi không xác định: $e');
      throw ServerException('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  /// Lấy token từ SharedPreferences
  /// 
  /// Trả về: String? - Token hoặc null nếu không tìm thấy
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      _logger.e('Lỗi khi lấy token: $e');
      return null;
    }
  }
}
