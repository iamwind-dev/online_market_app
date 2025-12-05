import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';
import '../../../../../core/services/search_service.dart';
import '../../../../../core/services/search_history_service.dart';
import '../../../../../core/dependency/injection.dart';

/// Cubit quản lý search
class SearchCubit extends Cubit<SearchState> {
  final SearchService _searchService = getIt<SearchService>();
  final SearchHistoryService _historyService = getIt<SearchHistoryService>();

  Timer? _debounceTimer;
  String _lastQuery = '';

  SearchCubit() : super(const SearchInitial());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Load lịch sử tìm kiếm
  void loadHistory() {
    final history = _historyService.getSearchHistory();
    emit(SearchInitial(searchHistory: history));
  }

  /// Suggest khi gõ - có debounce 300ms
  void suggest(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      loadHistory();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query.trim());
    });
  }

  /// Fetch suggestions từ API
  Future<void> _fetchSuggestions(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;

    final history = _historyService.getSearchHistory();
    emit(SearchSuggesting(query: query));

    try {
      final response = await _searchService.search(query);
      if (isClosed) return;

      if (response.data.isEmpty) {
        emit(SearchInitial(searchHistory: history));
      } else {
        emit(SearchSuggestionsLoaded(
          data: response.data,
          query: query,
          searchHistory: history,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(SearchInitial(searchHistory: history));
      }
    }
  }

  /// Tìm kiếm với query (khi submit)
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      loadHistory();
      return;
    }

    emit(const SearchLoading());

    try {
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
    _lastQuery = '';
    _debounceTimer?.cancel();
    loadHistory();
  }
}
