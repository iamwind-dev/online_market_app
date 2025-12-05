/// Utility class để format các trạng thái từ server
class StatusFormatter {
  StatusFormatter._();

  /// Format trạng thái đơn hàng
  /// Ví dụ: 'chua_thanh_toan' -> 'Chưa thanh toán'
  static String formatOrderStatus(String? status) {
    if (status == null || status.isEmpty) return 'Không xác định';

    switch (status.toLowerCase()) {
      // Trạng thái thanh toán
      case 'chua_thanh_toan':
        return 'Chưa thanh toán';
      case 'da_thanh_toan':
        return 'Đã thanh toán';
      case 'cho_thanh_toan':
        return 'Chờ thanh toán';
      case 'thanh_toan_that_bai':
        return 'Thanh toán thất bại';

      // Trạng thái đơn hàng
      case 'chua_xac_nhan':
        return 'Chưa xác nhận';
      case 'da_xac_nhan':
        return 'Đã xác nhận';
      case 'dang_xu_ly':
        return 'Đang xử lý';
      case 'dang_giao':
        return 'Đang giao hàng';
      case 'da_giao':
        return 'Đã giao hàng';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'da_huy':
      case 'huy':
        return 'Đã hủy';
      case 'tra_hang':
        return 'Trả hàng';
      case 'hoan_tien':
        return 'Hoàn tiền';

      // Trạng thái chung
      case 'pending':
        return 'Đang chờ';
      case 'processing':
        return 'Đang xử lý';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'paid':
        return 'Đã thanh toán';
      case 'unpaid':
        return 'Chưa thanh toán';

      default:
        // Nếu không match, convert snake_case thành Title Case
        return _snakeCaseToTitleCase(status);
    }
  }

  /// Format phương thức thanh toán
  static String formatPaymentMethod(String? method) {
    if (method == null || method.isEmpty) return 'Không xác định';

    switch (method.toLowerCase()) {
      case 'tien_mat':
      case 'cash':
      case 'cod':
        return 'Tiền mặt';
      case 'chuyen_khoan':
      case 'bank_transfer':
        return 'Chuyển khoản';
      case 'vnpay':
        return 'VNPay';
      case 'momo':
        return 'MoMo';
      case 'zalopay':
        return 'ZaloPay';
      default:
        return _snakeCaseToTitleCase(method);
    }
  }

  /// Format giới tính
  static String formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return 'Không xác định';

    switch (gender.toUpperCase()) {
      case 'M':
      case 'MALE':
      case 'NAM':
        return 'Nam';
      case 'F':
      case 'FEMALE':
      case 'NU':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  /// Format vai trò
  static String formatRole(String? role) {
    if (role == null || role.isEmpty) return 'Không xác định';

    switch (role.toLowerCase()) {
      case 'buyer':
      case 'nguoi_mua':
        return 'Người mua';
      case 'seller':
      case 'nguoi_ban':
        return 'Người bán';
      case 'admin':
        return 'Quản trị viên';
      default:
        return _snakeCaseToTitleCase(role);
    }
  }

  /// Convert snake_case thành Title Case
  /// Ví dụ: 'chua_thanh_toan' -> 'Chua Thanh Toan'
  static String _snakeCaseToTitleCase(String text) {
    return text
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  /// Lấy màu cho trạng thái đơn hàng
  static StatusColor getOrderStatusColor(String? status) {
    if (status == null || status.isEmpty) {
      return StatusColor.grey;
    }

    switch (status.toLowerCase()) {
      case 'da_thanh_toan':
      case 'paid':
      case 'hoan_thanh':
      case 'completed':
      case 'da_giao':
        return StatusColor.green;

      case 'dang_xu_ly':
      case 'processing':
      case 'dang_giao':
      case 'da_xac_nhan':
        return StatusColor.blue;

      case 'chua_thanh_toan':
      case 'unpaid':
      case 'cho_thanh_toan':
      case 'pending':
      case 'chua_xac_nhan':
        return StatusColor.orange;

      case 'da_huy':
      case 'huy':
      case 'cancelled':
      case 'thanh_toan_that_bai':
        return StatusColor.red;

      default:
        return StatusColor.grey;
    }
  }
}

/// Enum cho màu trạng thái
enum StatusColor {
  green,
  blue,
  orange,
  red,
  grey,
}
