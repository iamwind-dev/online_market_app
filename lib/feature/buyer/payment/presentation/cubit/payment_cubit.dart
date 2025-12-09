import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/services/vnpay_service.dart';
import '../../../../../core/services/cart_api_service.dart';
import '../../../../../core/services/user_profile_service.dart';

part 'payment_state.dart';

/// Payment Cubit quản lý logic nghiệp vụ của thanh toán
/// 
/// Chức năng chính:
/// - Tải thông tin đơn hàng
/// - Chọn phương thức thanh toán
/// - Xử lý thanh toán
class PaymentCubit extends Cubit<PaymentState> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  OrderSummary? _orderSummary;
  String? _maDonHang; // Mã đơn hàng từ API cart hoặc tạo mới
  bool _isBuyNow = false;
  
  PaymentCubit() : super(PaymentInitial());

  /// Tải thông tin đơn hàng
  Future<void> loadOrderSummary({
    bool isBuyNow = false,
    bool isFromCart = false,
    Map<String, dynamic>? orderData,
  }) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🎯 [PAYMENT] Bắt đầu tải thông tin đơn hàng');
      AppLogger.info('🎯 [PAYMENT] isBuyNow: $isBuyNow, isFromCart: $isFromCart');
    }

    try {
      emit(PaymentLoading());

      _isBuyNow = isBuyNow;

      if (isBuyNow && orderData != null) {
        // Mua ngay - tạo order summary từ dữ liệu truyền vào
        print('💳 [PAYMENT CUBIT] Creating order from buy now data');
        _orderSummary = _createOrderFromBuyNowData(orderData);
      } else if (isFromCart && orderData != null) {
        // Từ giỏ hàng - tạo order summary từ các items đã chọn
        print('💳 [PAYMENT CUBIT] Creating order from cart data');
        _orderSummary = _createOrderFromCartData(orderData);
      } else {
        // Fallback - Mock data
        await Future.delayed(const Duration(seconds: 1));
        
        // Check if cubit is still open before continuing
        if (isClosed) return;
        
        _orderSummary = _generateMockOrderSummary();
      }

      if (AppConfig.enableApiLogging) {
        AppLogger.info('✅ [PAYMENT] Tải thành công thông tin đơn hàng');
        AppLogger.info('💰 [PAYMENT] Tổng tiền: ${_orderSummary!.total}đ');
      }

      emit(PaymentLoaded(
        orderSummary: _orderSummary!,
        selectedPaymentMethod: _selectedPaymentMethod,
        orderCode: orderData?['orderCode'] as String?,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Lỗi khi tải thông tin: ${e.toString()}');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể tải thông tin đơn hàng: ${e.toString()}',
        ));
      }
    }
  }

  /// Tạo order summary từ dữ liệu "Mua ngay"
  OrderSummary _createOrderFromBuyNowData(Map<String, dynamic> data) {
    print('💳 [PAYMENT CUBIT] Buy now data: $data');
    
    final shopId = data['maGianHang'] as String? ?? '';
    final shopName = data['tenGianHang'] as String? ?? '';

    // Parse giá từ string (ví dụ: "89,000 đ" -> 89000)
    final priceStr = data['gia'] as String? ?? '0';
    final priceValue = double.tryParse(
      priceStr.replaceAll(RegExp(r'[^\d]'), '')
    ) ?? 0;
    
    final soLuong = data['soLuong'] as int? ?? 1;
    final totalPrice = priceValue * soLuong;
    
    return OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: [
        OrderItem(
          id: data['maNguyenLieu'] as String? ?? '',
          shopId: shopId,
          shopName: shopName,
          productName: data['tenNguyenLieu'] as String? ?? '',
          productImage: data['hinhAnh'] as String? ?? 'assets/img/payment_product.png',
          price: priceValue,
          weight: 1.0,
          unit: data['donVi'] as String? ?? 'KG',
          quantity: soLuong,
        ),
      ],
      subtotal: totalPrice,
      total: totalPrice,
    );
  }

  /// Tạo order summary từ dữ liệu giỏ hàng
  OrderSummary _createOrderFromCartData(Map<String, dynamic> data) {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT CUBIT] Cart data: $data');
    }
    
    final selectedItems = data['selectedItems'] as List<dynamic>? ?? [];
    final totalAmount = data['totalAmount'] as double? ?? 0;
    
    // Lưu mã đơn hàng nếu có (từ cart API)
    _maDonHang = data['orderCode'] as String?;
    
    // Convert selected items to OrderItem list
    final orderItems = selectedItems.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final priceStr = itemMap['gia'] as String? ?? '0';
      final priceValue = double.tryParse(
        priceStr.replaceAll(RegExp(r'[^\d.]'), '')
      ) ?? 0;
      
      // Lấy shopId - đảm bảo không empty
      final shopId = itemMap['maGianHang'] as String? ?? '';
      
      if (AppConfig.enableApiLogging) {
        AppLogger.info('💳 [PAYMENT] Item: maNguyenLieu=${itemMap['maNguyenLieu']}, maGianHang=$shopId');
      }
      
      return OrderItem(
        id: itemMap['maNguyenLieu'] as String? ?? '',
        shopId: shopId,
        shopName: itemMap['tenGianHang'] as String? ?? '',
        productName: itemMap['tenNguyenLieu'] as String? ?? '',
        productImage: itemMap['hinhAnh'] as String? ?? '',
        price: priceValue,
        weight: 1.0,
        unit: 'Cái',
        quantity: itemMap['soLuong'] as int? ?? 1,
      );
    }).toList();
    
    return OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: orderItems,
      subtotal: totalAmount,
      total: totalAmount ,
    );
  }

  /// Chọn phương thức thanh toán
  void selectPaymentMethod(PaymentMethod method) {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Chọn phương thức: ${method.name}');
    }

    _selectedPaymentMethod = method;

    if (_orderSummary != null) {
      emit(PaymentLoaded(
        orderSummary: _orderSummary!,
        selectedPaymentMethod: _selectedPaymentMethod,
        orderCode: _maDonHang,
      ));
    }
  }

  /// Check payment status (gọi khi app resume từ browser VNPay)
  /// Gọi API để kiểm tra trạng thái thanh toán thực tế
  Future<void> checkPaymentStatus() async {
    final currentState = state;
    String? maDonHang;
    
    // Lấy mã đơn hàng từ state hoặc biến instance
    if (currentState is PaymentLoaded && currentState.orderCode != null) {
      maDonHang = currentState.orderCode;
    } else {
      maDonHang = _maDonHang;
    }
    
    if (maDonHang == null || maDonHang.isEmpty) {
      if (AppConfig.enableApiLogging) {
        AppLogger.warning('⚠️ [PAYMENT] No order code available');
      }
      return;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] App resumed from browser');
      AppLogger.info('💳 [PAYMENT] Checking payment status for: $maDonHang');
    }

    try {
      emit(PaymentProcessing());
      
      // Gọi API để kiểm tra trạng thái đơn hàng
      final vnpayService = VNPayService();
      final orderStatus = await vnpayService.getOrderStatus(maDonHang);
      
      if (AppConfig.enableApiLogging) {
        AppLogger.info('💳 [PAYMENT] Order status: ${orderStatus.trangThai}');
        AppLogger.info('💳 [PAYMENT] Is paid: ${orderStatus.isPaid}');
      }
      
      if (isClosed) return;
      
      if (orderStatus.isPaid) {
        // Thanh toán thành công
        emit(PaymentSuccess(
          message: 'Thanh toán thành công!',
          orderId: maDonHang,
        ));
      } else if (orderStatus.isPending || orderStatus.trangThai == 'chua_xac_nhan') {
        // Đang chờ thanh toán - hiển thị thông báo yêu cầu thanh toán
        emit(PaymentPendingVNPay(
          orderId: maDonHang,
          message: 'Vui lòng thanh toán để xác nhận đơn hàng',
          orderSummary: _orderSummary!,
        ));
      } else if (orderStatus.isCancelled) {
        // Thanh toán bị hủy
        emit(const PaymentFailure(
          errorMessage: 'Thanh toán đã bị hủy. Vui lòng thử lại.',
        ));
      } else {
        // Trạng thái khác - navigate đến order detail để xem chi tiết
        emit(PaymentSuccess(
          message: 'Đơn hàng đã được xử lý!',
          orderId: maDonHang,
        ));
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Error checking status: $e');
      }
      if (!isClosed) {
        // Nếu lỗi, vẫn navigate đến order detail để user có thể xem
        emit(PaymentSuccess(
          message: 'Vui lòng kiểm tra trạng thái đơn hàng',
          orderId: maDonHang,
        ));
      }
    }
  }

  /// Verify payment result từ VNPay callback
  Future<void> verifyVNPayReturn(Map<String, String> queryParams) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Verifying VNPay return...');
      AppLogger.info('💳 [PAYMENT] Query params: $queryParams');
    }

    try {
      emit(PaymentProcessing());

      final vnpayService = VNPayService();
      final result = await vnpayService.verifyPaymentReturn(
        queryParams: queryParams,
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('💳 [PAYMENT] Verify result: ${result.success}');
        AppLogger.info('💳 [PAYMENT] Message: ${result.message}');
        AppLogger.info('💳 [PAYMENT] Order: ${result.maDonHang}');
        AppLogger.info('💳 [PAYMENT] Clear cart: ${result.clearCart}');
      }

      if (!isClosed) {
        if (result.success) {
          emit(PaymentSuccess(
            message: result.message,
            orderId: result.maDonHang,
          ));
        } else {
          emit(PaymentFailure(
            errorMessage: result.message,
          ));
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Verify error: $e');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể xác minh kết quả thanh toán: ${e.toString()}',
        ));
      }
    }
  }

  /// Xử lý thanh toán
  Future<void> processPayment() async {
    if (_orderSummary == null) {
      if (!isClosed) {
        emit(const PaymentFailure(
          errorMessage: 'Không có thông tin đơn hàng',
        ));
      }
      return;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Bắt đầu xử lý thanh toán');
      AppLogger.info('💳 [PAYMENT] Phương thức: ${_selectedPaymentMethod.name}');
      AppLogger.info('💰 [PAYMENT] Tổng tiền: ${_orderSummary!.total}đ');
    }

    try {
      emit(PaymentProcessing());

      if (_selectedPaymentMethod == PaymentMethod.vnpay) {
        // Xử lý thanh toán VNPay
        // Bước 1: Gọi API /api/buyer/cart/checkout để tạo đơn hàng
        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Step 1: Calling cart checkout API...');
        }
        
        // Validate items trước khi gọi API
        for (final item in _orderSummary!.items) {
          if (item.id.isEmpty) {
            throw Exception('Thiếu mã nguyên liệu cho sản phẩm: ${item.productName}');
          }
          if (item.shopId.isEmpty) {
            throw Exception('Thiếu mã gian hàng cho sản phẩm: ${item.productName}');
          }
        }
        
        // Lấy selectedItems từ _orderSummary với format đúng API yêu cầu
        // Input: { "selectedItems": [{ "ma_nguyen_lieu": "NL001", "ma_gian_hang": "GH001" }] }
        final selectedItems = _orderSummary!.items.map((item) => {
          'ma_nguyen_lieu': item.id,
          'ma_gian_hang': item.shopId,
        }).toList();

        if (selectedItems.isEmpty) {
          throw Exception('Không có sản phẩm nào được chọn để thanh toán');
        }

        // Chuẩn bị thông tin người nhận (re-use logic với COD)
        final userProfileService = UserProfileService();
        String userName = _orderSummary!.customerName;
        String phoneNumber =
            _normalizePhoneNumber(_orderSummary?.phoneNumber ?? '');
        if (phoneNumber.isEmpty) {
          phoneNumber = '0912345678';
        }
        String address = _orderSummary!.deliveryAddress;

        try {
          final profileResponse = await userProfileService.getProfile();
          final profile = profileResponse.data;

          if (profile.tenNguoiDung.isNotEmpty) {
            userName = profile.tenNguoiDung;
          }

          if (profile.sdt != null && profile.sdt!.isNotEmpty) {
            final normalized = _normalizePhoneNumber(profile.sdt!);
            if (normalized.isNotEmpty) {
              phoneNumber = normalized;
            }
          }

          if (profile.diaChi != null && profile.diaChi!.isNotEmpty) {
            address = profile.diaChi!;
          }
        } catch (_) {
          // bỏ qua, giữ fallback
        }

        if (_normalizePhoneNumber(phoneNumber).isEmpty) {
          phoneNumber = '0912345678';
        }

        final recipient = {
          'name': userName,
          'phone': phoneNumber,
          'address': address,
        };
        
        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Selected items: $selectedItems');
          AppLogger.info('💳 [PAYMENT] Recipient: $recipient');
        }
        
        final cartApiService = CartApiService();

        // Nếu là Mua ngay, đảm bảo item đã vào giỏ trước khi checkout
        if (_isBuyNow) {
          for (final item in _orderSummary!.items) {
            await cartApiService.addToCart(
              maNguyenLieu: item.id,
              maGianHang: item.shopId,
              soLuong: item.quantity.toDouble(),
            );
          }
        }

        final checkoutResponse = await cartApiService.checkout(
          selectedItems: selectedItems,
          // Backend chỉ chấp nhận 'chuyen_khoan' hoặc 'tien_mat'.
          // Dùng 'chuyen_khoan' để tạo đơn cho VNPay.
          paymentMethod: 'chuyen_khoan',
          recipient: recipient,
        );
        
        if (!checkoutResponse.success || checkoutResponse.maDonHang.isEmpty) {
          throw Exception('Checkout failed: Không nhận được mã đơn hàng');
        }
        
        final maDonHang = checkoutResponse.maDonHang;
        _maDonHang = maDonHang; // Lưu lại để dùng sau
        
        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [PAYMENT] Checkout success!');
          AppLogger.info('📝 [PAYMENT] ma_don_hang: $maDonHang');
          AppLogger.info('💰 [PAYMENT] tong_tien: ${checkoutResponse.tongTien}');
          AppLogger.info('📦 [PAYMENT] items_checkout: ${checkoutResponse.itemsCheckout}');
          AppLogger.info('💳 [PAYMENT] Step 2: Creating VNPay payment...');
        }
        
        // Bước 2: Gọi API /api/payment/vnpay/checkout với ma_don_hang từ bước 1
        // Input: { "ma_don_hang": "DHABC123", "bankCode": "NCB" }
        final vnpayService = VNPayService();
        final vnpayResponse = await vnpayService.createVNPayCheckout(
          maDonHang: maDonHang,
          bankCode: 'NCB',
        );
        
        if (vnpayResponse.success && vnpayResponse.redirect.isNotEmpty) {
          // Mở URL VNPay trong trình duyệt
          final url = Uri.parse(vnpayResponse.redirect);
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication, // Mở trong trình duyệt mặc định
            );
            
            if (AppConfig.enableApiLogging) {
              AppLogger.info('🎉 [PAYMENT] Đã mở VNPay payment URL');
              AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $maDonHang');
              AppLogger.info('📝 [PAYMENT] Mã thanh toán: ${vnpayResponse.maThanhToan}');
            }
            
            // Quay lại state PaymentLoaded để chờ user thanh toán xong và quay lại app
            // Khi app resume, checkPaymentStatus() sẽ được gọi
            if (!isClosed) {
              emit(PaymentLoaded(
                orderSummary: _orderSummary!,
                selectedPaymentMethod: _selectedPaymentMethod,
                orderCode: maDonHang, // Giữ mã đơn hàng để check status sau
              ));
            }
          } else {
            throw Exception('Không thể mở URL thanh toán VNPay');
          }
        } else {
          throw Exception('Không nhận được URL thanh toán từ VNPay');
        }
      } else {
        // Thanh toán khi nhận hàng (COD)
        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Processing COD payment...');
        }

        // Validate items
        for (final item in _orderSummary!.items) {
          if (item.id.isEmpty) {
            throw Exception(
                'Thiếu mã nguyên liệu cho sản phẩm: ${item.productName}');
          }
          if (item.shopId.isEmpty) {
            throw Exception(
                'Thiếu mã gian hàng cho sản phẩm: ${item.productName}');
          }
        }

        // Lấy selectedItems từ _orderSummary
        final selectedItems = _orderSummary!.items
            .map((item) => {
                  'ma_nguyen_lieu': item.id,
                  'ma_gian_hang': item.shopId,
                })
            .toList();

        // Lấy thông tin người nhận từ user profile
        final userProfileService = UserProfileService();
        String userName = _orderSummary!.customerName;
        // Ưu tiên số điện thoại từ order summary, fallback sau khi chuẩn hóa
        String phoneNumber =
            _normalizePhoneNumber(_orderSummary?.phoneNumber ?? '');
        if (phoneNumber.isEmpty) {
          phoneNumber = '0912345678'; // fallback an toàn
        }
        String address = _orderSummary!.deliveryAddress;

        try {
          final profileResponse = await userProfileService.getProfile();
          final profile = profileResponse.data;

          // Lấy tên từ profile
          if (profile.tenNguoiDung.isNotEmpty) {
            userName = profile.tenNguoiDung;
          }

          // Lấy số điện thoại từ profile
          if (profile.sdt != null && profile.sdt!.isNotEmpty) {
            final normalized = _normalizePhoneNumber(profile.sdt!);
            if (normalized.isNotEmpty) {
              phoneNumber = normalized;
            }
          }

          // Lấy địa chỉ từ profile
          if (profile.diaChi != null && profile.diaChi!.isNotEmpty) {
            address = profile.diaChi!;
          }

          if (AppConfig.enableApiLogging) {
            AppLogger.info('👤 [PAYMENT] User profile loaded');
            AppLogger.info('👤 [PAYMENT] Name: $userName');
            AppLogger.info('👤 [PAYMENT] Phone: $phoneNumber');
            AppLogger.info('👤 [PAYMENT] Address: $address');
          }
        } catch (e) {
          if (AppConfig.enableApiLogging) {
            AppLogger.warning(
                '⚠️ [PAYMENT] Could not load user profile, using defaults: $e');
          }
        }

        // Đảm bảo số điện thoại cuối cùng hợp lệ, nếu không fallback mặc định
        if (_normalizePhoneNumber(phoneNumber).isEmpty) {
          if (AppConfig.enableApiLogging) {
            AppLogger.warning(
                '⚠️ [PAYMENT] Invalid phone after normalization, using fallback');
          }
          phoneNumber = '0912345678';
        }

        final recipient = {
          'name': userName,
          'phone': phoneNumber,
          'address': address,
        };

        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Selected items: $selectedItems');
          AppLogger.info('💳 [PAYMENT] Recipient: $recipient');
        }

        // Gọi API checkout với payment_method = 'tien_mat'
        final cartApiService = CartApiService();
        final checkoutResponse = await cartApiService.checkout(
          selectedItems: selectedItems,
          paymentMethod: 'tien_mat',
          recipient: recipient,
        );

        if (isClosed) return;

        if (!checkoutResponse.success || checkoutResponse.maDonHang.isEmpty) {
          throw Exception('Checkout failed: Không nhận được mã đơn hàng');
        }

        final orderId = checkoutResponse.maDonHang;
        _maDonHang = orderId;

        if (AppConfig.enableApiLogging) {
          AppLogger.info('🎉 [PAYMENT] Đặt hàng COD thành công!');
          AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $orderId');
          AppLogger.info('💰 [PAYMENT] Tổng tiền: ${checkoutResponse.tongTien}');
        }

        emit(PaymentSuccess(
          message: 'Đặt hàng thành công! Thanh toán khi nhận hàng.',
          orderId: orderId,
        ));
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Lỗi khi xử lý thanh toán: ${e.toString()}');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể xử lý thanh toán: ${e.toString()}',
        ));
      }
    }
  }

  /// Get phương thức thanh toán đã chọn
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  /// Get tên phương thức thanh toán
  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Thanh toán khi giao';
      case PaymentMethod.vnpay:
        return 'VNpay';
    }
  }

  /// Generate mock order summary
  OrderSummary _generateMockOrderSummary() {
    return const OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: [
        OrderItem(
          id: '1',
          shopName: 'Cô Nhi',
          productName: 'Thịt đùi',
          productImage: 'assets/img/payment_product.png',
          price: 89000,
          weight: 0.7,
          unit: 'KG',
          quantity: 1,
        ),
      ],
      subtotal: 89000,
      total: 104000,
    );
  }

  /// Reset state về initial
  void resetState() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _orderSummary = null;
    emit(PaymentInitial());
  }

  /// Chuẩn hóa số điện thoại theo regex /^(0|\+84)\d{9,10}$/
  String _normalizePhoneNumber(String phone) {
    var normalized = phone.trim();
    // Loại bỏ khoảng trắng, dấu, giữ lại số và +
    normalized = normalized.replaceAll(RegExp(r'[^\d\+]'), '');

    if (normalized.startsWith('+84')) {
      normalized = '0${normalized.substring(3)}';
    }

    if (!normalized.startsWith('0')) {
      normalized = '0$normalized';
    }

    // Đảm bảo độ dài 10-11 chữ số
    if (normalized.length < 10 || normalized.length > 11) {
      return '';
    }

    return normalized;
  }
}
