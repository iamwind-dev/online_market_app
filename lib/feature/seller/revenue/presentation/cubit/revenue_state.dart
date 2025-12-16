import 'package:equatable/equatable.dart';

enum BalanceTab { pending, paid }
enum DateFilter { today, week, month }
enum ChartType { column, line }

class Transaction extends Equatable {
  final String id;
  final String orderId;
  final BalanceTab status;
  final double totalValue;
  final double serviceFee;
  final double actualAmount;

  const Transaction({
    required this.id,
    required this.orderId,
    required this.status,
    required this.totalValue,
    required this.serviceFee,
    required this.actualAmount,
  });

  @override
  List<Object?> get props => [id, orderId, status, totalValue, serviceFee, actualAmount];
}

class SellerRevenueState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final BalanceTab selectedBalanceTab;
  final DateFilter selectedDateFilter;
  final ChartType chartType;
  final double pendingBalance;
  final double paidBalance;
  final List<Transaction> transactions;
  final String nextSettlementCycle;

  const SellerRevenueState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedBalanceTab = BalanceTab.pending,
    this.selectedDateFilter = DateFilter.today,
    this.chartType = ChartType.column,
    this.pendingBalance = 0,
    this.paidBalance = 0,
    this.transactions = const [],
    this.nextSettlementCycle = 'Thứ Sáu, 17:00',
  });

  SellerRevenueState copyWith({
    bool? isLoading,
    String? errorMessage,
    BalanceTab? selectedBalanceTab,
    DateFilter? selectedDateFilter,
    ChartType? chartType,
    double? pendingBalance,
    double? paidBalance,
    List<Transaction>? transactions,
    String? nextSettlementCycle,
  }) {
    return SellerRevenueState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedBalanceTab: selectedBalanceTab ?? this.selectedBalanceTab,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      chartType: chartType ?? this.chartType,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      paidBalance: paidBalance ?? this.paidBalance,
      transactions: transactions ?? this.transactions,
      nextSettlementCycle: nextSettlementCycle ?? this.nextSettlementCycle,
    );
  }

  List<Transaction> get filteredTransactions {
    return transactions.where((t) => t.status == selectedBalanceTab).toList();
  }

  /// Factory method để tạo state với dữ liệu mẫu
  factory SellerRevenueState.withMockData() {
    final transactions = [
      const Transaction(
        id: '1',
        orderId: '#ORD-2024-001',
        status: BalanceTab.pending,
        totalValue: 250000,
        serviceFee: 25000,
        actualAmount: 225000,
      ),
      const Transaction(
        id: '2',
        orderId: '#ORD-2024-002',
        status: BalanceTab.paid,
        totalValue: 180000,
        serviceFee: 18000,
        actualAmount: 162000,
      ),
      const Transaction(
        id: '3',
        orderId: '#ORD-2024-003',
        status: BalanceTab.paid,
        totalValue: 320000,
        serviceFee: 32000,
        actualAmount: 288000,
      ),
    ];

    return SellerRevenueState(
      isLoading: false,
      selectedBalanceTab: BalanceTab.pending,
      selectedDateFilter: DateFilter.today,
      chartType: ChartType.column,
      pendingBalance: 350000,
      paidBalance: 2120000,
      transactions: transactions,
      nextSettlementCycle: 'Thứ Sáu, 17:00',
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        selectedBalanceTab,
        selectedDateFilter,
        chartType,
        pendingBalance,
        paidBalance,
        transactions,
        nextSettlementCycle,
      ];
}

