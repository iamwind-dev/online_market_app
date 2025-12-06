import 'package:equatable/equatable.dart';

/// State cho Home Screen
class HomeState extends Equatable {
  final String userName;
  final String searchQuery;
  final List<ChatMessage> chatMessages;
  final bool isTyping;
  final int selectedBottomNavIndex;
  final int cartItemCount;
  final String? errorMessage;
  final String? conversationId; // Thêm conversation ID

  const HomeState({
    this.userName = 'Quỳnh Như',
    this.searchQuery = '',
    this.chatMessages = const [],
    this.isTyping = false,
    this.selectedBottomNavIndex = 0,
    this.cartItemCount = 0,
    this.errorMessage,
    this.conversationId,
  });

  HomeState copyWith({
    String? userName,
    String? searchQuery,
    List<ChatMessage>? chatMessages,
    bool? isTyping,
    int? selectedBottomNavIndex,
    int? cartItemCount,
    String? errorMessage,
    String? conversationId,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      searchQuery: searchQuery ?? this.searchQuery,
      chatMessages: chatMessages ?? this.chatMessages,
      isTyping: isTyping ?? this.isTyping,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      errorMessage: errorMessage ?? this.errorMessage,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        searchQuery,
        chatMessages,
        isTyping,
        selectedBottomNavIndex,
        cartItemCount,
        errorMessage,
        conversationId,
      ];
}

/// Model cho tin nhắn chat
class ChatMessage extends Equatable {
  final String message;
  final bool isBot;
  final DateTime timestamp;
  final List<ChatOption>? options;
  final List<MonAnSuggestion>? monAnSuggestions; // Thêm suggestions món ăn
  final List<NguyenLieuSuggestion>? nguyenLieuSuggestions; // Thêm suggestions nguyên liệu

  const ChatMessage({
    required this.message,
    required this.isBot,
    required this.timestamp,
    this.options,
    this.monAnSuggestions,
    this.nguyenLieuSuggestions,
  });

  @override
  List<Object?> get props => [message, isBot, timestamp, options, monAnSuggestions, nguyenLieuSuggestions];
}

/// Model cho món ăn suggestion từ AI
class MonAnSuggestion extends Equatable {
  final String maMonAn;
  final String tenMonAn;
  final String hinhAnh;

  const MonAnSuggestion({
    required this.maMonAn,
    required this.tenMonAn,
    required this.hinhAnh,
  });

  @override
  List<Object?> get props => [maMonAn, tenMonAn, hinhAnh];
}

/// Model cho nguyên liệu suggestion từ AI
class NguyenLieuSuggestion extends Equatable {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String? donVi;
  final String? dinhLuong;
  final String? hinhAnh;
  final GianHangSuggest? gianHangSuggest;
  final bool canAddToCart;

  const NguyenLieuSuggestion({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    this.donVi,
    this.dinhLuong,
    this.hinhAnh,
    this.gianHangSuggest,
    this.canAddToCart = false,
  });

  @override
  List<Object?> get props => [maNguyenLieu, tenNguyenLieu, donVi, dinhLuong, hinhAnh, gianHangSuggest, canAddToCart];
}

/// Model cho gian hàng suggest
class GianHangSuggest extends Equatable {
  final String maGianHang;
  final String tenGianHang;
  final String viTri;
  final String gia;
  final String donViBan;
  final double soLuong;

  const GianHangSuggest({
    required this.maGianHang,
    required this.tenGianHang,
    required this.viTri,
    required this.gia,
    required this.donViBan,
    required this.soLuong,
  });

  @override
  List<Object?> get props => [maGianHang, tenGianHang, viTri, gia, donViBan, soLuong];
}

/// Model cho các lựa chọn trong chat
class ChatOption extends Equatable {
  final String label;
  final String value;
  final bool isSelected;

  const ChatOption({
    required this.label,
    required this.value,
    this.isSelected = false,
  });

  ChatOption copyWith({
    String? label,
    String? value,
    bool? isSelected,
  }) {
    return ChatOption(
      label: label ?? this.label,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [label, value, isSelected];
}