class ApiConstants {
  ApiConstants._();

  // Change to your LAN IP when testing on a physical device
  // e.g. 'http://192.168.1.10:3000'
  static const String _devBaseUrl = 'http://10.0.2.2:3000'; // Android emulator
  static const String _prodBaseUrl = 'https://mse-aggregation-platform.onrender.com';

  static const bool _isProduction = true;
  static const String baseUrl =
      _isProduction ? _prodBaseUrl : _devBaseUrl;

  static const String apiPrefix = '/api';

  // Auth
  static const String login    = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String logout   = '$apiPrefix/auth/logout';
  static const String me       = '$apiPrefix/auth/me';

  // Admin
  static const String adminDashboard         = '$apiPrefix/admin/dashboard';
  static const String adminOrders            = '$apiPrefix/admin/orders';
  static const String adminPendingMses       = '$apiPrefix/admin/mses/pending';
  static const String adminPendingSelections = '$apiPrefix/admin/selections/pending';
  static const String adminCompletedSelections = '$apiPrefix/admin/selections/completed';
  static const String adminRatings           = '$apiPrefix/admin/ratings';

  static String adminApproveMse(String id)         => '$apiPrefix/admin/mses/$id/approve';
  static String adminApproveSelection(String id)   => '$apiPrefix/admin/selections/$id/approve';
  static String adminRejectSelection(String id)    => '$apiPrefix/admin/selections/$id/reject';

  // MSE
  static const String mseDashboard   = '$apiPrefix/mse/dashboard';
  static const String mseOrders      = '$apiPrefix/mse/orders';
  static const String mseSelections  = '$apiPrefix/mse/selections';
  static const String mseRatings     = '$apiPrefix/mse/ratings';

  static String mseOrderDetail(String id)          => '$apiPrefix/mse/orders/$id';
  static String mseCompleteSelection(String id)    => '$apiPrefix/mse/selections/$id/complete';
}
