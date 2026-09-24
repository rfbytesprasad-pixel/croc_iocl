class ProductOption {
  final int id;
  final String name;
  const ProductOption(this.id, this.name);
}

const kProductOptions = <ProductOption>[
  ProductOption(1,  'MS'),
  ProductOption(2,  'HSD'),
  ProductOption(3,  'XTRAMILE'),
  ProductOption(4,  'OCTANE93'),
  ProductOption(5,  'XTRAPREMIUM'),
  ProductOption(6,  'LPG'),
  ProductOption(7,  'CNG'),
  ProductOption(8,  '100RON-10%Ethanol'),  // ← added, was missing
  ProductOption(9,  'X2'),
  ProductOption(10, 'Xtra Green'),
  ProductOption(11, 'CBG'),
  ProductOption(12, 'MS-BSVI-E20'),
  ProductOption(13, 'E-100'),
];

/// Central lookup: productId → product name.
String productNameFromId(int productId) {
  if (productId <= 0) return 'Unassigned';
  for (final p in kProductOptions) {
    if (p.id == productId) return p.name;
  }
  return 'Unassigned';   // unknown id
}