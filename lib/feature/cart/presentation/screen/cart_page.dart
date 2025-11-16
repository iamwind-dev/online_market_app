import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/cart_cubit.dart';

/// Màn hình giỏ hàng
/// 
/// Chức năng:
/// - Hiển thị danh sách sản phẩm trong giỏ
/// - Chọn/bỏ chọn sản phẩm
/// - Cập nhật số lượng
/// - Xóa sản phẩm
/// - Thanh toán
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit()..loadCart(),
      child: const CartView(),
    );
  }
}

/// View của màn hình giỏ hàng
class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CartCheckoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CartFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header with background
              _buildHeader(context),
              
              // Divider
              Container(
                height: 2,
                color: const Color(0xFFF0F0F0),
              ),
              
              // Content
              Expanded(
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    if (state is CartLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is CartLoaded) {
                      if (state.items.isEmpty) {
                        return _buildEmptyCart(context);
                      }
                      
                      return _buildCartList(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              
              // Bottom section
              _buildBottomSection(context),
              
              // Bottom navigation
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header với background và title
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background image
        
        // Content
        Container(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // Title row
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/img/arrow_left_cart.svg',
                      width: 25,
                      height: 26,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  const Text(
                    'Giỏ hàng',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.1,
                      color: Color(0xFF000000),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Placeholder to balance
                  const SizedBox(width: 25),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Address row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/location_icon_small.png',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Hòa Châu, Hòa Vang, Đà Nẵng',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.69,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/img/chevron_right.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFB3B3B3),
                      BlendMode.srcIn,
                    ),
                  ),
                  const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Xong',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.69,
                    color: Color(0xFFFF0004),
                  ),
                ),
              ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Giỏ hàng trống
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách sản phẩm trong giỏ
  Widget _buildCartList(BuildContext context, CartLoaded state) {
    // Group items by shop
    final itemsByShop = <String, List<CartItem>>{};
    for (final item in state.items) {
      if (!itemsByShop.containsKey(item.shopName)) {
        itemsByShop[item.shopName] = [];
      }
      itemsByShop[item.shopName]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: [
        // Select all section
        _buildSelectAllSection(context, state),
        
        const SizedBox(height: 16),
        
        // Cart items grouped by shop
        ...itemsByShop.entries.map((entry) {
          final shopName = entry.key;
          final items = entry.value;
          
          return Column(
            children: [
              _buildShopSection(context, shopName, items, state),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  /// Section chọn tất cả
  Widget _buildSelectAllSection(BuildContext context, CartLoaded state) {
    final cubit = context.read<CartCubit>();
    
    return Row(
      children: [
        GestureDetector(
          onTap: () => cubit.toggleSelectAll(),
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
              color: cubit.isAllSelected ? Colors.black : Colors.white,
            ),
            child: cubit.isAllSelected
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Tất cả',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.375,
            color: Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  /// Section của một shop
  Widget _buildShopSection(
    BuildContext context,
    String shopName,
    List<CartItem> items,
    CartLoaded state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD7FFBD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name
          Text(
            shopName,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
              color: Color(0xFF202020),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Products
          ...items.map((item) => Column(
                children: [
                  _buildCartItem(context, item, state),
                  if (item != items.last) const SizedBox(height: 16),
                ],
              )),
        ],
      ),
    );
  }

  /// Cart item widget
  Widget _buildCartItem(BuildContext context, CartItem item, CartLoaded state) {
    final cubit = context.read<CartCubit>();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        GestureDetector(
          onTap: () => cubit.toggleItemSelection(item.id),
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
              color: item.isSelected ? Colors.black : Colors.white,
            ),
            child: item.isSelected
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.productImage,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Product info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Text(
                '${item.productName} - (${item.weight}${item.unit})',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 1.375,
                  color: Color(0xFF202020),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Price
              Text(
                '${_formatPrice(item.price)}đ',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.29,
                  color: Color(0xFFFF0000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom section với tổng tiền và nút thanh toán
  Widget _buildBottomSection(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<CartCubit>();
        final isCheckingOut = state is CartCheckoutInProgress;

        return Container(
          height: 161,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFF000000), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Total section
              Row(
                children: [
                  // Select all checkbox
                  GestureDetector(
                    onTap: () => cubit.toggleSelectAll(),
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        color: cubit.isAllSelected ? Colors.black : Colors.white,
                      ),
                      child: cubit.isAllSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  const Text(
                    'Tất cả',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.375,
                      color: Color(0xFF202020),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Total price
                  Text(
                    '${_formatPrice(state.totalAmount)}đ',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.29,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Checkout button
              GestureDetector(
                onTap: isCheckingOut ? null : () => cubit.checkout(),
                child: Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F8000),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: isCheckingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Thanh toán',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.47,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Done text
              
            ],
          ),
        );
      },
    );
  }

  /// Bottom navigation
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/img/add_home.svg', 'Trang chủ'),
          _buildNavItem('assets/img/mon_an_icon.png', 'Món ăn', isImage: true),
          _buildNavItem('assets/img/user_personas_presentation-26cd3a.png', '', isImage: true, isCenter: true),
          _buildNavItem('assets/img/wifi_notification.svg', 'Thông báo'),
          _buildNavItem('assets/img/account_circle.svg', 'Tài khoản'),
        ],
      ),
    );
  }

  /// Navigation item
  Widget _buildNavItem(String icon, String label, {bool isImage = false, bool isCenter = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isCenter)
          Container(
            width: 58,
            height: 67,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(icon),
                fit: BoxFit.cover,
              ),
            ),
          )
        else ...[
          isImage
              ? Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                )
              : SvgPicture.asset(
                  icon,
                  width: 30,
                  height: 30,
                ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.33,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// Format price helper
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
