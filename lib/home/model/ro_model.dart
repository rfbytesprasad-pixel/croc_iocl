class RoModel {
  final int roCode;
  final String address;

  const RoModel({
    required this.roCode,
    required this.address,
  });

  /// Returned when /rodetails isn't available on the backend.
  /// Home shows placeholder values instead of a hard error.
  factory RoModel.empty() => const RoModel(roCode: 0, address: '—');

  factory RoModel.fromJson(Map<String, dynamic> json) {
    final data = json['rodetails'] is Map<String, dynamic>
        ? json['rodetails'] as Map<String, dynamic>
        : json;

    return RoModel(
      roCode: int.tryParse(data['rocode'].toString()) ?? 0,
      address: data['address']?.toString() ?? '',
    );
  }
}