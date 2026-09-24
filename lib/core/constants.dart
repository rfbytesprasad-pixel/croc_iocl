class AppConstants {
  /// Runtime-mutable. Updated by RoBloc after a successful /roconfig probe
  /// so all API clients (Pumps, Preset, Price Change) use the working IP.
  static String baseUrl = 'http://192.168.1.101';

  static const List<String> candidateIps = [
    '192.168.1.100',
    '192.168.1.101',
    '192.168.1.102',
    '192.168.1.103',
    '192.168.1.104',
    '192.168.1.105',
    '192.168.1.106',
    '192.168.1.107',
    '192.168.1.108',
    '192.168.1.109',
    '192.168.1.110',
  ];

  static const Duration pumpPollingInterval = Duration(seconds: 10);
}