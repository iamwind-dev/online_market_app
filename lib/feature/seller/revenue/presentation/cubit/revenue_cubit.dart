import 'package:flutter_bloc/flutter_bloc.dart';
import 'revenue_state.dart';

class SellerRevenueCubit extends Cubit<SellerRevenueState> {
  SellerRevenueCubit() : super(SellerRevenueState.withMockData());

  void selectBalanceTab(BalanceTab tab) {
    emit(state.copyWith(selectedBalanceTab: tab));
  }

  void selectDateFilter(DateFilter filter) {
    emit(state.copyWith(selectedDateFilter: filter));
  }

  void toggleChartType() {
    final newType = state.chartType == ChartType.column ? ChartType.line : ChartType.column;
    emit(state.copyWith(chartType: newType));
  }

  void requestSettlement() {
    // TODO: Implement settlement request
  }
}

