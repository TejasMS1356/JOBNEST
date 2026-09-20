import 'package:intl/intl.dart';

import '../core/app_config.dart';

/// Domain model for a single job listing.
///
/// Built from the Adzuna `/search` response, which frequently omits fields
/// (salary, contract type, company, ...), so every accessor degrades safely.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    this.description = '',
    this.contractTime,
    this.contractType,
    this.category,
    this.salaryMin,
    this.salaryMax,
    this.salaryIsPredicted = false,
    this.created,
    this.redirectUrl,
    this.currencySymbol = '£',
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String description;

  /// `full_time` / `part_time` from Adzuna.
  final String? contractTime;

  /// `permanent` / `contract` from Adzuna.
  final String? contractType;
  final String? category;
  final double? salaryMin;
  final double? salaryMax;
  final bool salaryIsPredicted;
  final DateTime? created;
  final String? redirectUrl;
  final String currencySymbol;

  factory Job.fromAdzuna(
    Map<String, dynamic> json, {
    String currencySymbol = '£',
  }) {
    final company = json['company'];
    final location = json['location'];
    final category = json['category'];

    return Job(
      id: '${json['id'] ?? json['adref'] ?? json['redirect_url'] ?? UniqueKey.next()}',
      title: _cleanText(json['title']) ?? 'Untitled role',
      company:
          _cleanText(company is Map ? company['display_name'] : null) ??
          'Confidential company',
      location:
          _cleanText(location is Map ? location['display_name'] : null) ??
          'Location not specified',
      description: _cleanText(json['description']) ?? '',
      contractTime: json['contract_time'] as String?,
      contractType: json['contract_type'] as String?,
      category: _cleanText(category is Map ? category['label'] : null),
      salaryMin: _toDouble(json['salary_min']),
      salaryMax: _toDouble(json['salary_max']),
      salaryIsPredicted: '${json['salary_is_predicted'] ?? '0'}' == '1',
      created: DateTime.tryParse('${json['created']}')?.toLocal(),
      redirectUrl: json['redirect_url'] as String?,
      currencySymbol: currencySymbol,
    );
  }

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: '${json['id']}',
    title: '${json['title']}',
    company: '${json['company']}',
    location: '${json['location']}',
    description: '${json['description'] ?? ''}',
    contractTime: json['contractTime'] as String?,
    contractType: json['contractType'] as String?,
    category: json['category'] as String?,
    salaryMin: _toDouble(json['salaryMin']),
    salaryMax: _toDouble(json['salaryMax']),
    salaryIsPredicted: json['salaryIsPredicted'] == true,
    created: DateTime.tryParse('${json['created']}'),
    redirectUrl: json['redirectUrl'] as String?,
    currencySymbol: json['currencySymbol'] as String? ?? '£',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'company': company,
    'location': location,
    'description': description,
    'contractTime': contractTime,
    'contractType': contractType,
    'category': category,
    'salaryMin': salaryMin,
    'salaryMax': salaryMax,
    'salaryIsPredicted': salaryIsPredicted,
    'created': created?.toIso8601String(),
    'redirectUrl': redirectUrl,
    'currencySymbol': currencySymbol,
  };

  /// Human label for the contract time, e.g. `Full time`.
  String get employmentType {
    final parts = <String>[
      if (contractTime != null) _humanize(contractTime!),
      if (contractType != null) _humanize(contractType!),
    ];
    if (parts.isEmpty) return 'Not specified';
    return parts.join(' · ');
  }

  static final RegExp _closedPattern = RegExp(
    r'\b(position (has been )?(filled|closed)|no longer (accepting|available|'
    r'open)|job (is )?closed|applications? closed|expired)\b',
    caseSensitive: false,
  );

  /// False for postings that are stale or state they are closed/filled.
  bool get isOpen {
    if (redirectUrl == null || redirectUrl!.isEmpty) return false;
    final age = created == null ? null : DateTime.now().difference(created!);
    if (age != null && age.inDays > AppConfig.maxDaysOld) return false;
    return !_closedPattern.hasMatch('$title $description');
  }

  /// Formatted salary/stipend range, or a fallback when Adzuna omits it.
  String get salaryLabel {
    final text = '$title $description'.toLowerCase();
    if (RegExp(r'\bunpaid\b|\bno stipend\b|\bwithout stipend\b|\bvolunteer\b')
        .hasMatch(text)) {
      return 'Unpaid';
    }

    // Adzuna India mixes annual CTC with monthly stipends and placeholder
    // values (₹0, ₹1, ₹15); drop noise below ₹1,000 and treat anything under
    // ₹1 lakh as a monthly figure.
    double? clean(double? v) => v == null || v < 1000 ? null : v;
    var min = clean(salaryMin);
    var max = clean(salaryMax);
    if (min == null && max == null) {
      final raw = salaryMax ?? salaryMin;
      if (raw != null && raw <= 1) return 'Unpaid';
      return 'Salary not disclosed';
    }
    if (min != null && max != null && min > max) {
      (min, max) = (max, min);
    }
    final monthly = currencySymbol == '₹' && (max ?? min!) < 100000;

    final String value;
    if (min != null && max != null && min != max) {
      value = '${_formatAmount(min)} – ${_formatAmount(max)}';
    } else {
      value = _formatAmount(min ?? max!);
    }
    final unit = monthly ? '/ mo' : '/ yr';
    return '$value $unit${salaryIsPredicted ? ' (est.)' : ''}';
  }

  /// Rupee amounts use the Indian lakh/crore convention (₹6.5L, ₹1.2Cr);
  /// other currencies use compact K/M notation.
  String _formatAmount(double amount) {
    if (currencySymbol == '₹') {
      if (amount >= 10000000) {
        return '₹${_trim(amount / 10000000)}Cr';
      }
      if (amount >= 100000) return '₹${_trim(amount / 100000)}L';
      if (amount >= 1000) return '₹${_trim(amount / 1000)}K';
      return '₹${amount.round()}';
    }
    return NumberFormat.compactCurrency(
      symbol: currencySymbol,
      decimalDigits: 0,
    ).format(amount);
  }

  static String _trim(double value) {
    final text = value.toStringAsFixed(value < 10 ? 1 : 0);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  String get postedLabel {
    final date = created;
    if (date == null) return 'Recently posted';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Just now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(date);
  }

  String get companyInitials {
    final words = company
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.characters(2);
    }
    return '${words[0].characters(1)}${words[1].characters(1)}';
  }

  /// Adzuna has no skills field, so skills are inferred from the description
  /// against a curated keyword list.
  List<String> get skills {
    final haystack = '$title $description $category'.toLowerCase();
    final found = _skillKeywords.where((skill) {
      final pattern = RegExp.escape(skill.toLowerCase());
      return RegExp('(?<![a-z0-9])$pattern(?![a-z])').hasMatch(haystack);
    }).toList();
    if (found.length < 3) {
      for (final skill in _roleSkills(title.toLowerCase())) {
        if (!found.contains(skill)) found.add(skill);
      }
    }
    return found.take(10).toList();
  }

  /// Typical skill set for a role when the posting itself names few.
  static List<String> _roleSkills(String title) {
    if (RegExp(r'web|front.?end|ui developer').hasMatch(title)) {
      return const ['HTML', 'CSS', 'JavaScript', 'React'];
    }
    if (RegExp(r'android|flutter|ios|mobile|app dev').hasMatch(title)) {
      return const ['Flutter', 'Kotlin', 'Java', 'REST APIs'];
    }
    if (RegExp(r'full.?stack|mern|node').hasMatch(title)) {
      return const ['JavaScript', 'React', 'Node.js', 'MongoDB'];
    }
    if (RegExp(r'data|machine learning|\bml\b|\bai\b|analyst')
        .hasMatch(title)) {
      return const ['Python', 'SQL', 'Machine Learning', 'Excel'];
    }
    if (RegExp(r'devops|cloud|sre|infrastructure').hasMatch(title)) {
      return const ['AWS', 'Docker', 'Kubernetes', 'Linux'];
    }
    if (RegExp(r'test|qa|quality').hasMatch(title)) {
      return const ['Selenium', 'Testing', 'Java', 'SQL'];
    }
    if (RegExp(r'account|financ|audit|tax|cfo|treasury').hasMatch(title)) {
      return const ['Accounting', 'Excel', 'Tally', 'GST'];
    }
    if (RegExp(r'java\b|python|\.net|c\+\+|backend|back.?end')
        .hasMatch(title)) {
      return const ['Java', 'Python', 'SQL', 'Git'];
    }
    if (RegExp(r'software|developer|engineer|programmer|sde').hasMatch(title)) {
      return const ['Data Structures', 'Java', 'Python', 'Git'];
    }
    return const ['Communication', 'Problem Solving', 'MS Office'];
  }

  /// Best-effort experience requirement parsed out of the description.
  String get experienceLabel {
    final text = description.toLowerCase();
    final range = RegExp(r'(\d{1,2})\s*[-–to]{1,3}\s*(\d{1,2})\+?\s*years?')
        .firstMatch(text);
    if (range != null) {
      return '${range.group(1)}–${range.group(2)} years';
    }
    final single = RegExp(r'(\d{1,2})\+?\s*years?').firstMatch(text);
    if (single != null) return '${single.group(1)}+ years';
    if (text.contains('graduate') ||
        text.contains('intern') ||
        text.contains('entry level')) {
      return 'Entry level';
    }
    if (text.contains('senior') || title.toLowerCase().contains('senior')) {
      return 'Senior level';
    }
    return 'Not specified';
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static String? _cleanText(Object? value) {
    if (value == null) return null;
    final text = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.isEmpty ? null : text;
  }

  static String _humanize(String raw) {
    final words = raw.split('_');
    return words
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static const List<String> _skillKeywords = [
    'HTML',
    'CSS',
    'Bootstrap',
    'Tailwind',
    'jQuery',
    'Next.js',
    'Express',
    'Django',
    'Flask',
    'Spring',
    'Git',
    'GitHub',
    'Data Structures',
    'Algorithms',
    'OOP',
    'REST APIs',
    'Firebase',
    'MySQL',
    'Docker',
    'Kubernetes',
    'Azure',
    'GCP',
    'Machine Learning',
    'Deep Learning',
    'Pandas',
    'NumPy',
    'TensorFlow',
    'Excel',
    'Communication',
    'Flutter',
    'Dart',
    'Android',
    'iOS',
    'Swift',
    'Kotlin',
    'Java',
    'Python',
    'JavaScript',
    'TypeScript',
    'React',
    'Angular',
    'Vue',
    'Node.js',
    'SQL',
    'NoSQL',
    'MongoDB',
    'PostgreSQL',
    'AWS',
    'CI/CD',
    'REST',
    'GraphQL',
    'Agile',
    'Scrum',
    'Testing',
    'Leadership',
    'Data Analysis',
    'Power BI',
    'Tableau',
    'SAP',
    'Salesforce',
    'Spring Boot',
    '.NET',
    'C++',
    'PHP',
    'Selenium',
    'DevOps',
    'Linux',
    'Digital Marketing',
    'SEO',
    'SEM',
    'Google Ads',
    'Social Media',
    'Content Writing',
    'Copywriting',
    'Brand Management',
    'Email Marketing',
    'Google Analytics',
    'HubSpot',
    'CRM',
    'Business Development',
    'Lead Generation',
    'Negotiation',
    'B2B Sales',
    'Account Management',
    'Client Relationship',
    'Market Research',
    'Strategy',
    'Product Management',
    'Project Management',
    'Stakeholder Management',
    'Accounting',
    'Tally',
    'GST',
    'Financial Analysis',
    'Budgeting',
    'Recruitment',
    'Figma',
    'Photoshop',
    'Canva',
    'UI/UX',
    'Presentation',
    'MS Office',
    'PowerPoint',
    'Problem Solving',
    'Teamwork',
  ];
}

extension on String {
  String characters(int count) =>
      substring(0, length < count ? length : count).toUpperCase();
}

/// Fallback id generator for listings that arrive without any identifier.
class UniqueKey {
  static int _counter = 0;
  static String next() => 'job-${_counter++}';
}
