import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/buyer_loading.dart';
import '../cubit/revenue_cubit.dart';
import '../cubit/revenue_state.dart';

class SellerRevenueScreen extends StatelessWidget {
  const SellerRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerRevenueCubit(),
      child: const SellerRevenueView(),
    );
  }
}

class SellerRevenueView extends StatelessWidget {
  const SellerRevenueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: BlocBuilder<SellerRevenueCubit, SellerRevenueState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const BuyerLoading(
                message: 'Đang tải dữ liệu doanh thu...',
              );
            }

            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildBalanceSummarySection(context, state),
                    _buildSettlementActionsSection(context, state),
                    _buildChartSection(context, state),
                    _buildTransactionHistorySection(context, state),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Header với back button và title
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            color: const Color(0xFF1F2937),
          ),
          const Expanded(
            child: Text(
              'Doanh thu & Tài chính',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.21,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Spacer để căn giữa title
        ],
      ),
    );
  }

  /// Balance Summary Section
  Widget _buildBalanceSummarySection(BuildContext context, SellerRevenueState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBalanceTab(
                    context,
                    label: 'Đang chờ',
                    tab: BalanceTab.pending,
                    isActive: state.selectedBalanceTab == BalanceTab.pending,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildBalanceTab(
                    context,
                    label: 'Đã thanh toán',
                    tab: BalanceTab.paid,
                    isActive: state.selectedBalanceTab == BalanceTab.paid,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Balance Display Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F8000), Color(0xFF2F8000)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedBalanceTab == BalanceTab.pending
                      ? 'Số dư đang chờ đối soát'
                      : 'Số dư đã thanh toán',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.21,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCurrency(
                    state.selectedBalanceTab == BalanceTab.pending
                        ? state.pendingBalance
                        : state.paidBalance,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    height: 1.21,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đồng',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.21,
                    color: Color(0xF2FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Date Filter Row
          Row(
            children: [
              Expanded(
                child: _buildDateFilter(
                  context,
                  label: 'Hôm nay',
                  filter: DateFilter.today,
                  isActive: state.selectedDateFilter == DateFilter.today,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateFilter(
                  context,
                  label: '7 ngày',
                  filter: DateFilter.week,
                  isActive: state.selectedDateFilter == DateFilter.week,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateFilter(
                  context,
                  label: '30 ngày',
                  filter: DateFilter.month,
                  isActive: state.selectedDateFilter == DateFilter.month,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTab(
    BuildContext context, {
    required String label,
    required BalanceTab tab,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.read<SellerRevenueCubit>().selectBalanceTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              height: 1.21,
              color: isActive ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter(
    BuildContext context, {
    required String label,
    required DateFilter filter,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.read<SellerRevenueCubit>().selectDateFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2F8000) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
              height: 1.21,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  /// Settlement Actions Section
  Widget _buildSettlementActionsSection(BuildContext context, SellerRevenueState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Settlement Main Button
          GestureDetector(
            onTap: () => context.read<SellerRevenueCubit>().requestSettlement(),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2F8000), Color(0xFF2F8000)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Yêu cầu Đối soát',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1.21,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cycle Notice Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chu kỳ đối soát tiếp theo: ${state.nextSettlementCycle}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.21,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // History Link Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch sử Đối soát',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.21,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Xem tất cả các lần thanh toán',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.21,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF1F2937),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chart Section
  Widget _buildChartSection(BuildContext context, SellerRevenueState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biểu đồ Doanh thu',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.21,
                  color: Color(0xFF000000),
                ),
              ),
              // Chart Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildChartToggle(
                      context,
                      label: 'Cột',
                      type: ChartType.column,
                      isActive: state.chartType == ChartType.column,
                    ),
                    const SizedBox(width: 4),
                    _buildChartToggle(
                      context,
                      label: 'Đường',
                      type: ChartType.line,
                      isActive: state.chartType == ChartType.line,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Detailed Chart Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chart Visual
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFF0FDF4), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: state.chartType == ChartType.column
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                height: 60 + (index * 10.0),
                              ),
                            );
                          }),
                        )
                      : const Center(
                          child: Text(
                            'Biểu đồ đường',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(
    BuildContext context, {
    required String label,
    required ChartType type,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.read<SellerRevenueCubit>().toggleChartType(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            height: 1.21,
            color: isActive ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  /// Transaction History Section
  Widget _buildTransactionHistorySection(BuildContext context, SellerRevenueState state) {
    final transactions = state.filteredTransactions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử Giao dịch',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.21,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Search Container
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                      SizedBox(width: 8),
                      Text(
                        'Tìm kiếm mã đơn hàng...',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.21,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune,
                  size: 20,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Transaction List
          ...transactions.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTransactionCard(context, transaction),
              )),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.orderId,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.21,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status == BalanceTab.pending ? 'Đang chờ' : 'Đã thanh toán',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.21,
                    color: transaction.status == BalanceTab.pending
                        ? const Color(0xFFD97706)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Transaction Details
          Column(
            children: [
              _buildDetailRow(
                label: 'Tổng giá trị',
                value: _formatCurrency(transaction.totalValue),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                label: 'Phí dịch vụ',
                value: _formatCurrency(transaction.serviceFee),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                label: 'Thực nhận',
                value: _formatCurrency(transaction.actualAmount),
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 13,
            height: 1.21,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            fontSize: isHighlight ? 15 : 13,
            height: 1.21,
            color: isHighlight ? const Color(0xFF2F8000) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted} Đ';
  }
}

