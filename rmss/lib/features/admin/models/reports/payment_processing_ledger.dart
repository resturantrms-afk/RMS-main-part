class PaymentProcessingLedger {
  final String userId;
  final String userName;
  final String userRole;
  final int totalOrdersProcessed;
  final double totalRevenueCollected;
  final String aiComment; // AI comment generated for this specific user's data

  PaymentProcessingLedger({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.totalOrdersProcessed,
    required this.totalRevenueCollected,
    required this.aiComment,
  });
}
