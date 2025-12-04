import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';
import '../../../../../core/services/search_service.dart';
import '../../../../../core/services/search_history_service.dart';
import '../../../../../core/dependency/injection.dart';

/// Cubit quản lý search
class SearchCubit extends Cubit<SearchState> {
  final SearchService _searchService = getIt<SearchService>();
  final SearchHistoryService _historyService = getIt<SearchHistoryService>();

  SearchCubit() : super(const SearchInitial());

  /// Load lịch sử tìm kiếm
  void loadHistory() {
    final history = _historyService.getSearchHistory();
    emit(SearchInitial(searchHistory: history));
  }

  /// Tìm kiếm với query
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      loadHistory();
      return;
    }

    emit(const SearchLoading());

    try {
      // Lưu vào lịch sử
      await _historyService.addSearchQuery(query.trim());
      
      final response = await _searchService.search(query.trim());

      if (response.data.isEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchSuccess(data: response.data, query: query));
      }
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  /// Xóa một item khỏi lịch sử
  Future<void> removeHistoryItem(String query) async {
    await _historyService.removeSearchQuery(query);
    loadHistory();
  }

  /// Xóa toàn bộ lịch sử
  Future<void> clearHistory() async {
    await _historyService.clearSearchHistory();
    loadHistory();
  }

  /// Clear search
  void clear() {
    loadHistory();
  }

  /// Gợi ý tìm kiếm realtime
  void suggest(String query) {
    if (query.trim().isEmpty) {
      loadHistory();
      return;
    }
    // TODO: Implement suggest logic with API call
  }
}
