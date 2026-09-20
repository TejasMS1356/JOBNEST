/// Job-type filters supported by the Adzuna search endpoint.
enum JobType {
  all('All jobs', null),
  fullTime('Full time', 'full_time'),
  partTime('Part time', 'part_time'),
  contract('Contract', 'contract'),
  permanent('Permanent', 'permanent'),
  internship('Internship', null);

  const JobType(this.label, this.queryFlag);

  final String label;

  /// Adzuna boolean query parameter, when one exists for this type.
  final String? queryFlag;
}

/// Adzuna job categories surfaced in the UI (tags from `/in/categories`).
///
/// JobNest focuses on software, tech and finance roles only; [all] fans out
/// to every focus category and merges the results.
enum JobCategory {
  all('All', null),
  tech(
    'Tech Jobs',
    'it-jobs',
    whatOr:
        'developer engineer programmer software web frontend backend '
        'android flutter ios mobile react angular java python',
  ),
  software('Software Engineer', 'it-jobs', what: 'software engineer'),
  fullStack(
    'Full Stack',
    'it-jobs',
    what: 'full stack',
    whatOr: 'developer engineer',
  ),
  data(
    'Data & AI',
    'it-jobs',
    whatOr: 'data machine-learning ai analyst python',
  ),
  cloud(
    'Cloud & DevOps',
    'it-jobs',
    whatOr: 'devops cloud aws azure kubernetes',
  ),
  finance('Finance & Accounting', 'accounting-finance-jobs'),
  fresher(
    'Fresher / Intern',
    'it-jobs',
    whatOr: 'fresher intern trainee graduate',
  );

  const JobCategory(this.label, this.tag, {this.what, this.whatOr});

  final String label;

  /// Adzuna `category` query value, when one exists.
  final String? tag;

  /// Extra terms that must all appear (Adzuna `what`).
  final String? what;

  /// Terms where any may appear (Adzuna `what_or`).
  final String? whatOr;

  /// Adzuna requests needed for this selection. "All" queries the broad IT
  /// and finance feeds and merges them.
  List<CategoryRequest> get requests => switch (this) {
    all => const [
      CategoryRequest(tag: 'it-jobs'),
      CategoryRequest(tag: 'accounting-finance-jobs'),
    ],
    _ => [CategoryRequest(tag: tag, what: what, whatOr: whatOr)],
  };
}

/// One Adzuna category query.
class CategoryRequest {
  const CategoryRequest({this.tag, this.what, this.whatOr});

  final String? tag;
  final String? what;
  final String? whatOr;
}

/// Major Indian job hubs offered in the location picker. An empty string
/// means "All India".
const List<String> indianCities = [
  'Bengaluru',
  'Hyderabad',
  'Mumbai',
  'Pune',
  'Chennai',
  'Delhi',
  'Gurugram',
  'Noida',
  'Kolkata',
  'Ahmedabad',
  'Jaipur',
  'Kochi',
  'Chandigarh',
  'Indore',
  'Coimbatore',
  'Thiruvananthapuram',
  'Bhubaneswar',
  'Lucknow',
  'Nagpur',
  'Visakhapatnam',
];

/// Client-side ordering applied to fetched results.
enum JobSort {
  relevance('Relevance'),
  newest('Newest'),
  oldest('Oldest'),
  salaryHighToLow('Salary: High to Low'),
  salaryLowToHigh('Salary: Low to High');

  const JobSort(this.label);

  final String label;
}

/// Immutable description of the current search.
class JobQuery {
  const JobQuery({
    this.keywords = '',
    this.location = '',
    this.type = JobType.all,
    this.category = JobCategory.all,
    this.sort = JobSort.relevance,
    this.page = 1,
  });

  final String keywords;
  final String location;
  final JobType type;
  final JobCategory category;
  final JobSort sort;
  final int page;

  JobQuery copyWith({
    String? keywords,
    String? location,
    JobType? type,
    JobCategory? category,
    JobSort? sort,
    int? page,
  }) => JobQuery(
    keywords: keywords ?? this.keywords,
    location: location ?? this.location,
    type: type ?? this.type,
    category: category ?? this.category,
    sort: sort ?? this.sort,
    page: page ?? this.page,
  );
}
