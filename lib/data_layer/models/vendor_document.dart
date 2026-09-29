/// Reading a `entrepreneurs/{uid}/vendorDetails/{vendorId}` document.
///
/// Two things about those documents are easy to get wrong, and both used to
/// crash at runtime rather than at compile time, so they live here once
/// instead of at every call site.

/// A budget value from Firestore, as a Dart double.
///
/// Firestore distinguishes integers from doubles on the wire, and the vendor
/// document has been written by two different clients: the old Flutter form
/// sent Dart doubles (always `doubleValue`), while the Media API sends numbers
/// parsed from JSON — and firebase-admin writes a whole number as an
/// `integerValue`. So `{from: 25000, to: 90000.5}` really does come back as
/// `{int, double}`.
///
/// `Map<String, double>.from(...)` on that throws
/// "type 'int' is not a subtype of type 'double' in type cast". Going through
/// `num` accepts either and normalises to double, which is what the widgets
/// want.
double vendorNumber(dynamic raw, {double fallback = 0}) {
  if (raw is num) return raw.toDouble();

  // Defensive: a value stored as a string by some older path still shows a
  // number rather than crashing the whole screen.
  if (raw is String) return double.tryParse(raw) ?? fallback;

  return fallback;
}

/// The `budget` map, accepting int or double for either bound.
///
/// A missing or malformed budget yields zeros rather than throwing: a vendor
/// listing with an odd budget should still be readable and editable.
Map<String, double> vendorBudget(dynamic raw) {
  if (raw is! Map) return {'from': 0, 'to': 0};

  return {
    'from': vendorNumber(raw['from']),
    'to': vendorNumber(raw['to']),
  };
}

/// The `images` array as a list of plain maps.
///
/// Tolerates a missing or null field — an older listing may have none — so
/// callers get an empty list instead of a cast error.
List<Map<String, dynamic>> vendorImages(dynamic raw) {
  if (raw is! List) return const [];

  return raw
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList();
}

/// The image reference for one entry of `images`.
///
/// Two generations of writer, two field names, and both must keep working:
///
///  * `imagePath`  — written since the R2 migration. An R2 object key.
///  * `imageUrl`   — written before it. A Firebase Storage download URL.
///
/// The resolver already tells an object key from a URL, so the only job here
/// is to find whichever field this document happens to carry. Returns null
/// when neither is present, which every caller renders as a placeholder.
String? vendorImageRef(Map<String, dynamic> entry) {
  final path = entry['imagePath'];
  if (path is String && path.trim().isNotEmpty) return path;

  final url = entry['imageUrl'];
  if (url is String && url.trim().isNotEmpty) return url;

  return null;
}

/// The caption for one entry of `images`.
String vendorImageCaption(Map<String, dynamic> entry) {
  final text = entry['text'];
  return text is String ? text : '';
}
