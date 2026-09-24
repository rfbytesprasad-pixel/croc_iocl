/// ─────────────────────────────────────────────────────────────────────────────
/// RoConfigModel — matches the real /roconfig packet:
///
/// {
///   "type": "roconfig",
///   "roConfig": {
///     "roCode": 166616,
///     "roName": "Test",
///     "totalDUs": 2,
///     "totalTanks": 2,
///     "totalPumps": 4,
///     "duList": [
///       {
///         "duNo": 1,
///         "deviceId": 163456002049768,
///         "totalPumps": 2,
///         "nozzleCount": 4,
///         "pumpIds": [1, 2],
///         "pumpList": [
///           {
///             "pumpId": 1,
///             "pumpNo": 1,
///             "pumpType": 1,
///             "nozzleCount": 2,
///             "nozzleList": [
///               {"nozzleNo": 1, "productNo": 1, "tankNo": 1},
///               {"nozzleNo": 2, "productNo": 2, "tankNo": 2}
///             ]
///           }
///         ]
///       }
///     ]
///   }
/// }
///
/// Parsing is defensive: every field is read with case-insensitive key lookup
/// and multiple fallbacks, because the source docx had OCR artefacts. This
/// means the model tolerates `duNo` / `duno` / `DU_NO` / `du_no` etc.
/// ─────────────────────────────────────────────────────────────────────────────
class RoConfigModel {
  final int roCode;
  final String roName;
  final int totalDUs;
  final int totalTanks;
  final int totalPumps;
  final List<DuConfig> duList;

  const RoConfigModel({
    required this.roCode,
    required this.roName,
    required this.totalDUs,
    required this.totalTanks,
    required this.totalPumps,
    required this.duList,
  });

  factory RoConfigModel.fromJson(Map<String, dynamic> json) {
    // Response may be wrapped in "roConfig", "roconfig", or unwrapped.
    final raw = json['roConfig'] ?? json['roconfig'] ?? json;
    final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    return RoConfigModel(
      roCode: _asInt(data, ['roCode', 'rocode', 'RO_CODE']),
      roName: _asString(data, ['roName', 'roname', 'RO_NAME']),
      totalDUs: _asInt(data, ['totalDUs', 'totaldus', 'TOTAL_DUS']),
      totalTanks: _asInt(data, ['totalTanks', 'totaltanks', 'TOTAL_TANKS']),
      totalPumps: _asInt(data, ['totalPumps', 'totalpumps', 'TOTAL_PUMPS']),
      duList: _parseList(
        _pick(data, ['duList', 'dulist', 'DU_LIST']),
        (e) => DuConfig.fromJson(e),
      ),
    );
  }
}

class DuConfig {
  final int duNo;
  final int deviceId;
  final int totalPumps;
  final int nozzleCount;
  final List<int> pumpIds;
  final List<PumpConfig> pumpList;

  const DuConfig({
    required this.duNo,
    required this.deviceId,
    required this.totalPumps,
    required this.nozzleCount,
    required this.pumpIds,
    required this.pumpList,
  });

  factory DuConfig.fromJson(Map<String, dynamic> json) {
    return DuConfig(
      duNo: _asInt(json, ['duNo', 'duno', 'DU_NO', 'du_no']),
      deviceId: _asInt(json, ['deviceId', 'deviceid', 'deviceld', 'DEVICE_ID']),
      totalPumps: _asInt(json, ['totalPumps', 'totalpumps', 'TOTAL_PUMPS']),
      nozzleCount: _asInt(json, ['nozzleCount', 'nozzlecount', 'NOZZLE_COUNT']),
      pumpIds: _parseIntList(
        _pick(json, ['pumpIds', 'pumpids', 'PUMP_IDS']),
      ),
      pumpList: _parseList(
        _pick(json, ['pumpList', 'pumplist', 'PUMP_LIST']),
        (e) => PumpConfig.fromJson(e),
      ),
    );
  }
}

class PumpConfig {
  final int pumpId;
  final int pumpNo;
  final int pumpType;
  final int nozzleCount;
  final List<NozzleConfig> nozzleList;

  const PumpConfig({
    required this.pumpId,
    required this.pumpNo,
    required this.pumpType,
    required this.nozzleCount,
    required this.nozzleList,
  });

  factory PumpConfig.fromJson(Map<String, dynamic> json) {
    return PumpConfig(
      pumpId: _asInt(json, ['pumpId', 'pumpid', 'PUMP_ID']),
      pumpNo: _asInt(json, ['pumpNo', 'pumpno', 'PUMP_NO']),
      pumpType: _asInt(json, ['pumpType', 'pumptype', 'PUMP_TYPE']),
      nozzleCount: _asInt(json, ['nozzleCount', 'nozzlecount', 'NOZZLE_COUNT']),
      nozzleList: _parseList(
        _pick(json, ['nozzleList', 'nozzlelist', 'NOZZLE_LIST']),
        (e) => NozzleConfig.fromJson(e),
      ),
    );
  }
}

class NozzleConfig {
  final int nozzleNo;
  final int productNo;
  final int tankNo;

  const NozzleConfig({
    required this.nozzleNo,
    required this.productNo,
    required this.tankNo,
  });

  factory NozzleConfig.fromJson(Map<String, dynamic> json) {
    return NozzleConfig(
      nozzleNo: _asInt(json, ['nozzleNo', 'nozzleno', 'NOZZLE_NO']),
      productNo: _asInt(json, ['productNo', 'productno', 'PRODUCT_NO']),
      tankNo: _asInt(json, ['tankNo', 'tankno', 'TANK_NO']),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Defensive parsing helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the first non-null value found among [keys].
dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

int _asInt(Map<String, dynamic> json, List<String> keys) {
  final v = _pick(json, keys);
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _asString(Map<String, dynamic> json, List<String> keys) {
  final v = _pick(json, keys);
  if (v == null) return '';
  return v.toString();
}

List<int> _parseIntList(dynamic raw) {
  if (raw is List) {
    return raw
        .map((e) {
          if (e is int) return e;
          if (e is num) return e.toInt();
          return int.tryParse(e.toString());
        })
        .whereType<int>()
        .toList();
  }
  return const [];
}

List<T> _parseList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }
  return [];
}