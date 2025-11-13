import 'package:equatable/equatable.dart';

/// Base state for Home feature
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when home screen is first loaded
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State when home screen is loading data
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State when home screen data is loaded successfully
class HomeLoaded extends HomeState {
  final String selectedMarket;
  final int selectedBottomNavIndex;
  final String searchQuery;

  const HomeLoaded({
    this.selectedMarket = 'Chọn chợ',
    this.selectedBottomNavIndex = 0,
    this.searchQuery = '',
  });

  HomeLoaded copyWith({
    String? selectedMarket,
    int? selectedBottomNavIndex,
    String? searchQuery,
  }) {
    return HomeLoaded(
      selectedMarket: selectedMarket ?? this.selectedMarket,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [selectedMarket, selectedBottomNavIndex, searchQuery];
}

/// State when an error occurs
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
