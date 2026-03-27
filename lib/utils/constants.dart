// Kuwait Real Estate CRM Constants

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://zqiqimzhodphvmlvwsoy.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpxaXFpbXpob2RwaHZtbHZ3c295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NjgxNTEsImV4cCI6MjA4OTI0NDE1MX0.DpG0Q_qllYXEdwI6z5wB85bVBuLZDpkfsopMJNt1lyg';

  // App Info
  static const String appName = 'سمسار عقاري';
  static const String appNameEn = 'Simsar Aqari';
  static const String countryCode = '+965';

  // Property Purposes
  static const List<String> purposes = [
    'للبيع',
    'للإيجار',
    'للبدل',
    'مطلوب',
  ];

  // Property Types
  static const List<String> propertyTypes = [
    'بيت',
    'شقة',
    'أرض',
    'عمارة',
    'فيلا',
    'دور',
    'محل تجاري',
    'مزرعة',
    'شاليه',
    'مخزن',
    'استوديو',
  ];

  // Kuwait Governorates and their Areas
  static const Map<String, List<String>> governorates = {
    'العاصمة': [
      'الشرق', 'دسمان', 'الصوابر', 'المرقاب', 'القبلة', 'الصالحية',
      'بنيد القار', 'كيفان', 'الدسمة', 'الدعية', 'المنصورية', 'ضاحية عبدالله السالم',
      'النزهة', 'الفيحاء', 'الشامية', 'الروضة', 'العديلية', 'الخالدية',
      'القادسية', 'قرطبة', 'السرة', 'اليرموك', 'الشويخ', 'الري',
      'غرناطة', 'الصليبيخات', 'الدوحة', 'النهضة', 'جابر الأحمد', 'القيروان',
    ],
    'حولي': [
      'حولي', 'السالمية', 'الرميثية', 'الجابرية', 'مشرف', 'بيان',
      'البدع', 'النقرة', 'ميدان حولي', 'الشهداء', 'الزهراء', 'سلوى',
      'جنوب السرة', 'السلام', 'حطين', 'الشعب',
    ],
    'الفروانية': [
      'الفروانية', 'خيطان', 'العمرية', 'جليب الشيوخ', 'الأندلس', 'إشبيلية',
      'الرابية', 'الرحاب', 'صباح الناصر', 'عبدالله المبارك', 'الفردوس',
      'العارضية', 'الري', 'الشدادية', 'الحسينية',
    ],
    'مبارك الكبير': [
      'المسيلة', 'صبحان', 'مبارك الكبير', 'العدان', 'القصور', 'القرين',
      'صباح السالم', 'المسايل', 'أبو فطيرة', 'أبو حليفة', 'الفنيطيس',
      'الفنطاس', 'المهبولة',
    ],
    'الأحمدي': [
      'الأحمدي', 'الفحيحيل', 'الفنطاس', 'المنقف', 'أبو حليفة', 'الرقة',
      'هدية', 'الصباحية', 'أم الهيمان', 'علي صباح السالم', 'جابر العلي',
      'الوفرة', 'الزور', 'بنيدر', 'الخيران', 'ميناء عبدالله',
    ],
    'الجهراء': [
      'الجهراء', 'القصر', 'تيماء', 'النسيم', 'العيون', 'القيصرية',
      'النعيم', 'الواحة', 'العبدلي', 'الصليبية', 'صبحان', 'أمغرة',
      'كبد', 'سعد العبدالله', 'جنوب الجهراء',
    ],
  };

  // Property Status
  static const List<String> statusOptions = [
    'approved',
    'pending',
    'rejected',
    'sold',
  ];
}
