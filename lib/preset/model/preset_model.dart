// lib/preset/model/preset_model.dart

// ── Preset modes from your doc ─────────────────────────────────────────────────
enum PresetMode {
  volume(2, 'Volume'),
  amount(1, 'Amount');

  final int code;
  final String label;
  const PresetMode(this.code, this.label);
}

// ── MOP — Method of Payment ────────────────────────────────────────────────────
enum PresetMop {
  cash(0, 'Cash'),
  card(1, 'Card'),
  upi(2, 'UPI');

  final int code;
  final String label;
  const PresetMop(this.code, this.label);
}
enum PresetOperation {
  normalPreset(2, 'Normal Preset'),
  presetAck(5, 'Preset ACK');

  final int code;
  final String label;
  const PresetOperation(this.code, this.label);
}

// ── Request model ──────────────────────────────────────────────────────────────
// ── Request model ──────────────────────────────────────────────────────────────
class PresetRequest {
  final int roAutoId;
  final int duid;
  final int pumpAutoId;
  final int nozzleAutoId;
  final PresetOperation operationId;
  final PresetMode presetMode;
  final PresetMop presetMop;
  final String presetValue;
  final int updateBy;

  const PresetRequest({
    required this.roAutoId,
    required this.duid,
    required this.pumpAutoId,
    required this.nozzleAutoId,
    required this.operationId,
    required this.presetMode,
    required this.presetMop,
    required this.presetValue,
    required this.updateBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'PRESET',
      'data': {
        'roautoid:INTEGER': roAutoId.toString(),
        'duid:INTEGER': duid.toString(),
        'pumpautoid:INTEGER': pumpAutoId.toString(),
        'nozzleautoid:INTEGER': nozzleAutoId.toString(),
        'operationid:INTEGER': operationId.code.toString(),
        'presetmode:INTEGER': presetMode.code.toString(),
        'presetmop:INTEGER': presetMop.code.toString(),
        'presetvalue:TEXT': presetValue,
        'updateby:INTEGER': updateBy.toString(),
      },
    };
  }
}

// ── Response model ─────────────────────────────────────────────────────────────
enum PresetResponseStatus {
  pending, // 0
  success, // 1 or "success"
  failure, // "failure"
  unknown,
}

class PresetResponse {
  final PresetResponseStatus status;
  final String displayMessage;

  const PresetResponse({
    required this.status,
    required this.displayMessage,
  });

  factory PresetResponse.fromJson(Map<String, dynamic> json) {
    // Doc says: 0=pending, 1/"success"=success, "failure"=failed
    final raw =
        (json['status'] ?? json['result'] ?? 0).toString().toLowerCase();

    final PresetResponseStatus status;
    final String message;

    if (raw == '1' || raw == 'success') {
      status = PresetResponseStatus.success;
      message = 'Preset applied successfully.';
    } else if (raw == 'failure') {
      status = PresetResponseStatus.failure;
      message = 'Preset operation failed. Please try again.';
    } else if (raw == '0') {
      status = PresetResponseStatus.pending;
      message = 'Preset received. Pending application.';
    } else {
      status = PresetResponseStatus.unknown;
      message = 'Unknown response from server.';
    }

    return PresetResponse(status: status, displayMessage: message);
  }
}
