class TankStatusModel {
  final String slaveMac;
  final int tankAutoId;
  final int interLockValue;
  final int status;
  final int productId;

  final double productLevel;
  final double waterLevel;
  final double waterVolume;
  final double temperature;
  final double ullage;
  final double productVolume;
  final double density;

  const TankStatusModel({
    required this.slaveMac,
    required this.tankAutoId,
    required this.interLockValue,
    required this.status,
    required this.productId,
    required this.productLevel,
    required this.waterLevel,
    required this.waterVolume,
    required this.temperature,
    required this.ullage,
    required this.productVolume,
    required this.density,
  });

  factory TankStatusModel.fromJson(Map<String, dynamic> json) {
    // Support:
    // { "tankstatus": {...} }
    // and:
    // { "slaveMac": "...", ... }

    final Map<String, dynamic> data = json['tankstatus'] is Map<String, dynamic>
        ? json['tankstatus'] as Map<String, dynamic>
        : json;

    dynamic getValue(String key) {
      if (data.containsKey(key)) {
        return data[key];
      }

      // Supports typed keys such as:
      // tankAutoId:INTEGER
      // productLevel:INTEGER
      // productVolume:INTEGER
      for (final entry in data.entries) {
        if (entry.key.split(':').first.toLowerCase() == key.toLowerCase()) {
          return entry.value;
        }
      }

      return null;
    }

    int parseInt(
      String key, {
      int fallback = 0,
    }) {
      final value = getValue(key);

      if (value == null) return fallback;

      if (value is int) return value;

      if (value is num) return value.toInt();

      final parsed = int.tryParse(value.toString());

      return parsed ?? fallback;
    }

    double parseDouble(
      String key, {
      double fallback = 0.0,
    }) {
      final value = getValue(key);

      if (value == null) return fallback;

      if (value is double) return value;

      if (value is num) return value.toDouble();

      final parsed = double.tryParse(value.toString());

      return parsed ?? fallback;
    }

    return TankStatusModel(
      slaveMac: getValue('slaveMac')?.toString() ?? '00:00:00:00:00:00',
      tankAutoId: parseInt('tankAutoId'),
      interLockValue: parseInt('interLockValue'),
      status: parseInt('status'),
      productId: parseInt('productId'),
      productLevel: parseDouble(
        'productLevel',
        fallback: 0.0,
      ),
      waterLevel: parseDouble(
        'waterLevel',
        fallback: 0.0,
      ),
      waterVolume: parseDouble(
        'waterVolume',
        fallback: 0.0,
      ),
      temperature: parseDouble(
        'temperature',
        fallback: 0.0,
      ),
      ullage: parseDouble(
        'ullage',
        fallback: 0.0,
      ),
      productVolume: parseDouble(
        'productVolume',
        fallback: 0.0,
      ),
      density: parseDouble(
        'density',
        fallback: 0.0,
      ),
    );
  }
}
