import '../models/job.dart';
import '../models/job_filter.dart';

/// Offline demo dataset used when no Adzuna credentials are configured.
///
/// It keeps the UI (and screenshots/tests) fully functional without a key;
/// real data is used as soon as `ADZUNA_APP_ID`/`ADZUNA_APP_KEY` are provided.
List<Job> sampleJobs(JobQuery query) {
  final keywords = query.keywords.trim().toLowerCase();
  final location = query.location.trim().toLowerCase();

  return _demoJobs.where((job) {
    final matchesKeywords =
        keywords.isEmpty ||
        '${job.title} ${job.company} ${job.description} ${job.category}'
            .toLowerCase()
            .contains(keywords);
    final matchesLocation =
        location.isEmpty || job.location.toLowerCase().contains(location);
    final matchesType = switch (query.type) {
      JobType.all => true,
      JobType.fullTime => job.contractTime == 'full_time',
      JobType.partTime => job.contractTime == 'part_time',
      JobType.contract => job.contractType == 'contract',
      JobType.permanent => job.contractType == 'permanent',
      JobType.internship => job.title.toLowerCase().contains('intern'),
    };
    final category = (job.category ?? '').toLowerCase();
    final title = job.title.toLowerCase();
    final matchesCategory = switch (query.category) {
      JobCategory.all => true,
      JobCategory.finance => category.contains('financ'),
      JobCategory.tech => category.contains('it'),
      JobCategory.fullStack => title.contains('full'),
      JobCategory.data => title.contains('data'),
      JobCategory.cloud => title.contains('devops') || title.contains('cloud'),
      JobCategory.fresher =>
        title.contains('intern') || title.contains('junior'),
      JobCategory.software => category.contains('it'),
    };
    return matchesKeywords && matchesLocation && matchesType && matchesCategory;
  }).toList();
}

final List<Job> _demoJobs = [
  Job(
    id: 'demo-1',
    title: 'Senior Flutter Engineer',
    company: 'Northwind Labs',
    location: 'Bengaluru, Karnataka',
    description: 'We are looking for a Senior Flutter Engineer with 5+ years of mobile experience to own our cross-platform product. You will work with Dart, REST APIs, Firebase and CI/CD pipelines, mentor engineers and drive architecture decisions across Android and iOS.',
    contractTime: 'full_time',
    contractType: 'permanent',
    category: 'IT Jobs',
    salaryMin: 7500000,
    salaryMax: 9500000,
    created: DateTime.now().subtract(const Duration(hours: 5)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-2',
    title: 'Mobile App Developer (Android)',
    company: 'Brightpath Digital',
    location: 'Hyderabad, Telangana',
    description: 'Join a product team building consumer Android apps in Kotlin and Java. 3 to 5 years of experience with REST integrations, Git, Agile delivery and automated testing is required.',
    contractTime: 'full_time',
    contractType: 'permanent',
    category: 'IT Jobs',
    salaryMin: 5200000,
    salaryMax: 6400000,
    created: DateTime.now().subtract(const Duration(days: 1)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-3',
    title: 'Software Engineering Intern',
    company: 'Orbital Systems',
    location: 'Pune, Maharashtra',
    description: 'A 6 month internship for graduates. You will learn Python, SQL and Docker while shipping internal tooling with a supportive mentor. Entry level candidates welcome; stipend paid monthly.',
    contractTime: 'full_time',
    contractType: 'contract',
    category: 'Graduate Jobs',
    salaryMin: 2400000,
    salaryMax: 2400000,
    salaryIsPredicted: true,
    created: DateTime.now().subtract(const Duration(days: 2)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-4',
    title: 'Backend Developer (Node.js)',
    company: 'Cobalt Fintech',
    location: 'Remote, India',
    description: 'Design and scale payment APIs using Node.js, TypeScript, PostgreSQL and AWS. 4+ years experience with REST and GraphQL services, Kubernetes and CI/CD expected.',
    contractTime: 'full_time',
    contractType: 'contract',
    category: 'IT Jobs',
    salaryMin: 240000,
    salaryMax: 300000,
    created: DateTime.now().subtract(const Duration(days: 3)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-5',
    title: 'Part Time UX Designer',
    company: 'Studio Fern',
    location: 'Mumbai, Maharashtra',
    description: 'Shape delightful product experiences 3 days a week. Strong communication skills, Figma craft and 2-4 years of design experience in agile teams.',
    contractTime: 'part_time',
    contractType: 'permanent',
    category: 'Creative & Design Jobs',
    salaryMin: 3200000,
    salaryMax: 3800000,
    created: DateTime.now().subtract(const Duration(days: 4)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-6',
    title: 'Data Analyst',
    company: 'Meridian Retail',
    location: 'Chennai, Tamil Nadu',
    description: 'Turn commercial data into decisions using SQL, Excel and Python. Experience with data analysis dashboards and stakeholder communication required, 2+ years.',
    contractTime: 'full_time',
    contractType: 'permanent',
    category: 'Consultancy Jobs',
    salaryMin: 3800000,
    salaryMax: 4500000,
    created: DateTime.now().subtract(const Duration(days: 6)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-7',
    title: 'Cloud Platform Engineer',
    company: 'Helix Cloud',
    location: 'Gurugram, Haryana',
    description: 'Own infrastructure across AWS and Azure with Docker, Kubernetes and Terraform. Senior engineers with 6+ years of platform experience preferred.',
    contractTime: 'full_time',
    contractType: 'permanent',
    category: 'IT Jobs',
    salaryMin: 6800000,
    salaryMax: 8200000,
    created: DateTime.now().subtract(const Duration(days: 8)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
  Job(
    id: 'demo-8',
    title: 'Marketing Intern',
    company: 'Lumen Media',
    location: 'Delhi, India',
    description: 'Support campaign delivery and reporting. Entry level role with a monthly stipend, ideal for students. Strong communication and Excel skills needed.',
    contractTime: 'part_time',
    contractType: 'contract',
    category: 'PR, Advertising & Marketing Jobs',
    created: DateTime.now().subtract(const Duration(days: 9)),
    redirectUrl: 'https://www.adzuna.in/',
    currencySymbol: '₹',
  ),
];
