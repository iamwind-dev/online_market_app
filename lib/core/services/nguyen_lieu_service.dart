import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nguyen_lieu_model.dart';
import '../models/nguyen_lieu_detail_model.dart';
import '../error/exceptions.dart';
import 'package:logger/logger.dart';

/// Service để gọi API nguyên liệu
class NguyenLieuService {
  static const String _baseUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';
  static const String _endpointList = '/nguyen-lieu';
  static const String _tokenKey = 'auth_token';

  final Dio _dio;
  final Logger _logger = Logger();

  NguyenLieuService({Dio? dio}) : _dio = dio ?? Dio();

  /// Lấy danh sách nguyên liệu từ API
  /// 
  /// [page] - Trang hiện tại (mặc định: 1)
  /// [limit] - Số lượng nguyên liệu trên 1 trang (mặc định: 12)
  /// 
  /// Trả về: List<NguyenLieuModel> - Danh sách nguyên liệu
  /// 
  /// Throws:
  /// - UnauthorizedException: Nếu token không hợp lệ hoặc hết hạn
  /// - NetworkException: Nếu có lỗi kết nối
  /// - ServerException: Nếu server trả về lỗi
  Future<List<NguyenLieuModel>> getNguyenLieuList({
    int page = 1,
    int limit = 12,
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
          _logger.e('Timeout khi gọi API danh sách nguyên liệu');
          throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
        },
      );

      // 5. Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 6. Parse response
        final data = response.data as Map<String, dynamic>;
        
        // 7. Lấy danh sách nguyên liệu từ data
        final nguyenLieuJson = data['data'] as List<dynamic>? ?? [];
        final nguyenLieuList = nguyenLieuJson
            .map((item) => NguyenLieuModel.fromJson(item as Map<String, dynamic>))
            .toList();

        _logger.i('API trả về ${nguyenLieuList.length} nguyên liệu');

        return nguyenLieuList;
      } else if (response.statusCode == 401) {
        _logger.e('Token không hợp lệ hoặc hết hạn');
        throw UnauthorizedException('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else {
        _logger.e('Lỗi server: ${response.statusCode}');
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on UnauthorizedException {
      _logger.e('UnauthorizedException khi lấy danh sách nguyên liệu');
      rethrow;
    } on NetworkException {
      _logger.e('NetworkException khi lấy danh sách nguyên liệu');
      rethrow;
    } on ServerException {
      _logger.e('ServerException khi lấy danh sách nguyên liệu');
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

  /// Lấy chi tiết nguyên liệu từ API
  /// 
  /// [maNguyenLieu] - Mã nguyên liệu cần lấy chi tiết
  /// 
  /// Trả về: NguyenLieuDetailModel - Thông tin chi tiết nguyên liệu
  /// 
  /// Throws:
  /// - UnauthorizedException: Nếu token không hợp lệ hoặc hết hạn
  /// - NetworkException: Nếu có lỗi kết nối
  /// - ServerException: Nếu server trả về lỗi
  Future<NguyenLieuDetailModel> getNguyenLieuDetail(String maNguyenLieu) async {
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

      // 3. Gửi GET request
      final url = '$_baseUrl$_endpointList/$maNguyenLieu';
      _logger.i('Gọi API: GET $url');

      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Timeout khi gọi API chi tiết nguyên liệu');
          throw NetworkException('Kết nối bị timeout, vui lòng thử lại');
        },
      );

      // 4. Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 5. Parse response
        final data = response.data as Map<String, dynamic>;
        final detail = NguyenLieuDetailModel.fromJson(data);

        _logger.i('API trả về chi tiết nguyên liệu: ${detail.tenNguyenLieu}');
        _logger.i('Số người bán: ${detail.sellers.length}');

        return detail;
      } else if (response.statusCode == 401) {
        _logger.e('Token không hợp lệ hoặc hết hạn');
        throw UnauthorizedException('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else if (response.statusCode == 404) {
        _logger.e('Không tìm thấy nguyên liệu: $maNguyenLieu');
        throw ServerException('Không tìm thấy nguyên liệu');
      } else {
        _logger.e('Lỗi server: ${response.statusCode}');
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on UnauthorizedException {
      _logger.e('UnauthorizedException khi lấy chi tiết nguyên liệu');
      rethrow;
    } on NetworkException {
      _logger.e('NetworkException khi lấy chi tiết nguyên liệu');
      rethrow;
    } on ServerException {
      _logger.e('ServerException khi lấy chi tiết nguyên liệu');
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
        throw ServerException('Không tìm thấy nguyên liệu');
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
