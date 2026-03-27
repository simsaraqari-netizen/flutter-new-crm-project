class UserProfile {
  final String id;
  final String? email;
  final String? name;
  final String role;
  final String? accountType;
  final String? companyName;
  final String? companyLicense;
  final String? phone;
  final String? whatsapp;
  final String? bio;
  final String? website;
  final String? twitter;
  final String? instagram;
  final String? tiktok;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.name,
    this.role = 'user',
    this.accountType,
    this.companyName,
    this.companyLicense,
    this.phone,
    this.whatsapp,
    this.bio,
    this.website,
    this.twitter,
    this.instagram,
    this.tiktok,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isAgent => role == 'agent';
  bool get isPending => role == 'pending';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'user',
      accountType: json['account_type'] as String?,
      companyName: json['company_name'] as String?,
      companyLicense: json['company_license'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      twitter: json['twitter'] as String?,
      instagram: json['instagram'] as String?,
      tiktok: json['tiktok'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'account_type': accountType,
      'company_name': companyName,
      'company_license': companyLicense,
      'phone': phone,
      'whatsapp': whatsapp,
      'bio': bio,
      'website': website,
      'twitter': twitter,
      'instagram': instagram,
      'tiktok': tiktok,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? accountType,
    String? companyName,
    String? companyLicense,
    String? phone,
    String? whatsapp,
    String? bio,
    String? website,
    String? twitter,
    String? instagram,
    String? tiktok,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      accountType: accountType ?? this.accountType,
      companyName: companyName ?? this.companyName,
      companyLicense: companyLicense ?? this.companyLicense,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
