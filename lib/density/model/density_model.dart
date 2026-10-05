// lib/density/model/density_model.dart

// ── Request — what we send to the ESP ─────────────────────────────────────
class DensityRequest {
  final int roAutoId;
  final int tankAutoId;
  final int productId;
  final double density;
  final int updateBy;

  const DensityRequest({
    required this.roAutoId,
    required this.tankAutoId,
    required this.productId,
    required this.density,
    required this.updateBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'DENSITYCHANGE',
      'data': {
        'roautoid:INTEGER': roAutoId.toString(),
        'tankautoid:INTEGER': tankAutoId.toString(),
        'productid:INTEGER': productId.toString(),
        'density:INTEGER': density.toStringAsFixed(2),
        'updateby:INTEGER': updateBy.toString(),
      },
    };
  }
}

// ── Response — what the ESP sends back ────────────────────────────────────
enum DensityResponseStatus { pending, success, failure, unknown }

class DensityResponse {
  final DensityResponseStatus status;
  final String displayMessage;

  const DensityResponse({
    required this.status,
    required this.displayMessage,
  });

  factory DensityResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['status'] ?? json['updateflag'] ?? 0)
        .toString()
        .toLowerCase();

    if (raw == '1' || raw == 'success') {
      return const DensityResponse(
        status: DensityResponseStatus.success,
        displayMessage: 'Density change applied successfully.',
      );
    } else if (raw == 'failure') {
      return const DensityResponse(
        status: DensityResponseStatus.failure,
        displayMessage: 'Density change failed. Please try again.',
      );
    } else if (raw == '0') {
      return const DensityResponse(
        status: DensityResponseStatus.pending,
        displayMessage: 'Density change received. Pending application.',
      );
    }
    return const DensityResponse(
      status: DensityResponseStatus.unknown,
      displayMessage: 'Unknown response from server.',
    );
  }
}