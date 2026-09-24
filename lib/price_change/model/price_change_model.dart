// lib/price_change/model/price_change_model.dart



// Re-export so any existing import of
// 'package:croc_iocl_atos/price_change/model/price_change_model.dart'
// that uses ProductOption / kProductOptions keeps working.
export 'package:croc_iocl_atos/constants/product_options.dart'
    show ProductOption, kProductOptions;

// ── Request model — what we send to the API ────────────────────────────────────
class PriceChangeRequest {
  final String roCode;
  final int roAutoId;
  final int productAutoId;
  final double price;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final int updateBy;
  final int id;

  const PriceChangeRequest({
    required this.roCode,
    required this.roAutoId,
    required this.productAutoId,
    required this.price,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.updateBy,
    this.id = 0,
  });

  // ── Converts to the exact JSON shape your API expects ─────────────────────
  Map<String, dynamic> toJson() {
    return {
      'rocode': roCode,
      'type': 'PRICECHANGE',
      'table': 'priceChange',
      'operation': 1,
      'data': {
        'id:INTEGER': id.toString(),
        'roautoid:INTEGER': roAutoId.toString(),
        'productautoid:INTEGER': productAutoId.toString(),
        'price:INTEGER': price.toString(),
        'effectivefrom:TEXT': _formatDateTime(effectiveFrom),
        'effectiveto:TEXT': _formatDateTime(effectiveTo),
        'updateby:INTEGER': updateBy.toString(),
      },
    };
  }

  // ── Format: "2025-08-22 11:11:11" ─────────────────────────────────────────
  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

// ── Response model — what the API sends back ───────────────────────────────────
enum PriceChangeResponseStatus {
  pending, // 0 — packet received, not yet applied
  success, // 1 — applied successfully
  unknown, // anything else
}

class PriceChangeResponse {
  final PriceChangeResponseStatus status;
  final String displayMessage;

  const PriceChangeResponse({
    required this.status,
    required this.displayMessage,
  });

  factory PriceChangeResponse.fromJson(Map<String, dynamic> json) {
    // API returns 0 or 1 — could be int or string, handle both
    final raw = json['status'] ?? json['updateflag'] ?? 0;
    final code = int.tryParse(raw.toString()) ?? 0;

    switch (code) {
      case 1:
        return const PriceChangeResponse(
          status: PriceChangeResponseStatus.success,
          displayMessage: 'Price change applied successfully.',
        );
      case 0:
        return const PriceChangeResponse(
          status: PriceChangeResponseStatus.pending,
          displayMessage: 'Price change received. Pending application.',
        );
      default:
        return const PriceChangeResponse(
          status: PriceChangeResponseStatus.unknown,
          displayMessage: 'Unknown response from server.',
        );
    }
  }
}