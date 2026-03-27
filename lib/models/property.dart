class Property {
  final String id;
  final String? ownerId;
  final String title;
  final String? purpose;
  final String? type;
  final String? pt;
  final String? gov;
  final String? loc;
  final String? location;
  final double price;
  final String? phone;
  final String? description;
  final String? seller;
  final List<String> images;
  final String? photo;
  final DateTime createdAt;
  final String? sector;
  final String? block;
  final String? street;
  final String? avenue;
  final String? plotNumber;
  final String? houseNumber;
  final String? details;
  final String? lastComment;
  final String? status;
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final bool isSold;
  final String? companyId;

  Property({
    required this.id,
    this.ownerId,
    required this.title,
    this.purpose,
    this.type,
    this.pt,
    this.gov,
    this.loc,
    this.location,
    this.price = 0,
    this.phone,
    this.description,
    this.seller,
    this.images = const [],
    this.photo,
    required this.createdAt,
    this.sector,
    this.block,
    this.street,
    this.avenue,
    this.plotNumber,
    this.houseNumber,
    this.details,
    this.lastComment,
    this.status = 'approved',
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.isSold = false,
    this.companyId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String?,
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String?,
      type: json['type'] as String?,
      pt: json['pt'] as String?,
      gov: json['gov'] as String?,
      loc: json['loc'] as String?,
      location: json['location'] as String?,
      price: _parseDouble(json['price']),
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      seller: json['seller'] as String?,
      images: _parseImages(json['images']),
      photo: json['photo'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      sector: json['sector'] as String?,
      block: json['block'] as String?,
      street: json['street'] as String?,
      avenue: json['avenue'] as String?,
      plotNumber: json['plot_number'] as String?,
      houseNumber: json['house_number'] as String?,
      details: json['details'] as String?,
      lastComment: json['last_comment'] as String?,
      status: json['status'] as String? ?? 'approved',
      assignedEmployeeId: json['assigned_employee_id'] as String?,
      assignedEmployeeName: json['assigned_employee_name'] as String?,
      isSold: json['is_sold'] as bool? ?? false,
      companyId: json['company_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'purpose': purpose,
      'type': type,
      'pt': pt,
      'gov': gov,
      'loc': loc,
      'location': location,
      'price': price,
      'phone': phone,
      'description': description,
      'seller': seller,
      'images': images,
      'photo': photo,
      'sector': sector,
      'block': block,
      'street': street,
      'avenue': avenue,
      'plot_number': plotNumber,
      'house_number': houseNumber,
      'details': details,
      'last_comment': lastComment,
      'status': status,
      'assigned_employee_id': assignedEmployeeId,
      'assigned_employee_name': assignedEmployeeName,
      'is_sold': isSold,
      'company_id': companyId,
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? purpose,
    String? type,
    String? pt,
    String? gov,
    String? loc,
    String? location,
    double? price,
    String? phone,
    String? description,
    String? seller,
    List<String>? images,
    String? photo,
    DateTime? createdAt,
    String? sector,
    String? block,
    String? street,
    String? avenue,
    String? plotNumber,
    String? houseNumber,
    String? details,
    String? lastComment,
    String? status,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    bool? isSold,
    String? companyId,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      type: type ?? this.type,
      pt: pt ?? this.pt,
      gov: gov ?? this.gov,
      loc: loc ?? this.loc,
      location: location ?? this.location,
      price: price ?? this.price,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      seller: seller ?? this.seller,
      images: images ?? this.images,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      sector: sector ?? this.sector,
      block: block ?? this.block,
      street: street ?? this.street,
      avenue: avenue ?? this.avenue,
      plotNumber: plotNumber ?? this.plotNumber,
      houseNumber: houseNumber ?? this.houseNumber,
      details: details ?? this.details,
      lastComment: lastComment ?? this.lastComment,
      status: status ?? this.status,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      isSold: isSold ?? this.isSold,
      companyId: companyId ?? this.companyId,
    );
  }

  /// Display-friendly location string
  String get displayLocation {
    final parts = <String>[];
    if (gov != null && gov!.isNotEmpty) parts.add(gov!);
    if (loc != null && loc!.isNotEmpty) parts.add(loc!);
    if (sector != null && sector!.isNotEmpty) parts.add('قطعة $sector');
    if (block != null && block!.isNotEmpty) parts.add('قطعة $block');
    return parts.isEmpty ? (location ?? title) : parts.join(' - ');
  }

  /// Display-friendly price string
  String get displayPrice {
    if (price <= 0) return 'السعر غير محدد';
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)} مليون د.ك';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)} ألف د.ك';
    }
    return '${price.toStringAsFixed(0)} د.ك';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
