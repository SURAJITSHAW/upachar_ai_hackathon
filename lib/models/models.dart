import 'dart:convert';

class Medicine {
  Medicine({
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.route,
    required this.time,
    required this.timeLabel,
    this.taken = false,
    this.needsReview = false,
  });

  String name;
  String dosage;
  String quantity; // e.g. "1 Tablet", "2 Tablets"
  String route; // e.g. "Orally"
  String time; // "08:00 AM"
  String timeLabel; // "Fasting", "After Breakfast"
  bool taken;
  bool needsReview;

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'quantity': quantity,
    'route': route,
    'time': time,
    'timeLabel': timeLabel,
    'taken': taken,
    'needsReview': needsReview,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    name: json['name'] as String,
    dosage: json['dosage'] as String,
    quantity: json['quantity'] as String,
    route: json['route'] as String,
    time: json['time'] as String,
    timeLabel: json['timeLabel'] as String,
    taken: json['taken'] as bool? ?? false,
    needsReview: json['needsReview'] as bool? ?? false,
  );
}

class Prescription {
  Prescription({
    required this.id,
    required this.doctorName,
    required this.scannedAt,
    required this.medicines,
    this.warnings = const [],
  });

  final String id;
  final String doctorName;
  final DateTime scannedAt;
  final List<Medicine> medicines;
  final List<String> warnings;

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorName': doctorName,
    'scannedAt': scannedAt.toIso8601String(),
    'medicines': medicines.map((m) => m.toJson()).toList(),
    'warnings': warnings,
  };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json['id'] as String,
    doctorName: json['doctorName'] as String,
    scannedAt: DateTime.parse(json['scannedAt'] as String),
    medicines: (json['medicines'] as List)
        .map((m) => Medicine.fromJson(m as Map<String, dynamic>))
        .toList(),
    warnings: (json['warnings'] as List?)?.cast<String>() ?? const [],
  );
}

class FamilyProfile {
  FamilyProfile({
    required this.id,
    required this.name,
    this.prescriptions = const [],
  });

  final String id;
  String name;
  List<Prescription> prescriptions;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
  };

  factory FamilyProfile.fromJson(Map<String, dynamic> json) => FamilyProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    prescriptions: (json['prescriptions'] as List? ?? [])
        .map((p) => Prescription.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  static String encodeList(List<FamilyProfile> profiles) =>
      jsonEncode(profiles.map((p) => p.toJson()).toList());

  static List<FamilyProfile> decodeList(String raw) => (jsonDecode(raw) as List)
      .map((p) => FamilyProfile.fromJson(p as Map<String, dynamic>))
      .toList();
}
