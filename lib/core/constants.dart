class AppConstants {
  /// Runtime-mutable. Updated by RoBloc after a successful /roconfig probe.
  static String baseUrl = 'http://192.168.1.101';

  /// Probe both known subnets — the ESP has appeared on .1.x and .4.x
  /// across different Wi-Fi networks.
  static const List<String> candidateIps = [
    // 192.168.1.x
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
    // 192.168.4.x
    '192.168.4.100',
    '192.168.4.101',
    '192.168.4.102',
    '192.168.4.103',
    '192.168.4.104',
    '192.168.4.105',
    '192.168.4.106',
    '192.168.4.107',
    '192.168.4.108',
    '192.168.4.109',
    '192.168.4.110',
  ];

  static const Duration pumpPollingInterval = Duration(seconds: 10);
}
