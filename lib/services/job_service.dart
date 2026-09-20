import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import 'sample_jobs.dart';

/// Error raised by [JobService] with a user-presentable [message].
class JobServiceException implements Exception {
  JobServiceException(
    this.message, {
    this.isNetworkError = false,
    this.isRateLimit = false,
  });

  final String message;
  final bool isNetworkError;
  final bool isRateLimit;

  @override
  String toString() => message;
}

/// Thin REST client around the Adzuna jobs API.
///
/// The service is the only layer that knows about HTTP; providers consume
/// plain [Job] models.
class JobService {
  JobService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Map<String, String> _currencyByCountry = {
    'gb': '£',
    'us': r'$',
    'ca': r'$',
    'au': r'$',
    'nz': r'$',
    'in': '₹',
    'de': '€',
    'fr': '€',
    'es': '€',
    'it': '€',
    'nl': '€',
    'at': '€',
    'be': '€',
    'pl': 'zł',
    'br': r'R$',
    'za': 'R',
    'sg': r'S$',
    'ch': 'CHF',
    'mx': r'$',
  };

  /// Fetches one page of listings for [query].
  ///
  /// Falls back to a bundled demo dataset when no Adzuna credentials were
  /// supplied at build time, so the UI remains usable offline.
  Future<List<Job>> fetchJobs(JobQuery query) async {
    if (!AppConfig.hasCredentials) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return _sorted(sampleJobs(query), query.sort);
    }

    final requests = query.category.requests;
    if (requests.length == 1) {
      return _sorted(await _fetchCategory(query, requests.first), query.sort);
    }

    // Adzuna's rate limiter rejects concurrent bursts, so fetch sequentially
    // and retry a throttled category once before giving up on it.
    final pages = <List<Job>>[];
    Object? lastError;
    for (final request in requests) {
      try {
        pages.add(await _fetchCategory(query, request));
      } on JobServiceException catch (e) {
        if (!e.isRateLimit) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        try {
          pages.add(await _fetchCategory(query, request));
        } on JobServiceException catch (retryError) {
          lastError = retryError;
        }
      }
    }
    if (pages.isEmpty && lastError != null) throw lastError;

    final seen = <String>{};
    return _sorted([
      for (final page in pages)
        for (final job in page)
          if (seen.add(job.id)) job,
    ], query.sort);
  }

  /// Orders [jobs] per [sort]; entries missing the sort key go last.
  static List<Job> _sorted(List<Job> jobs, JobSort sort) {
    double? salary(Job j) => j.salaryMax ?? j.salaryMin;
    int compareNullable<T extends Comparable<T>>(T? a, T? b, bool desc) {
      if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
      return desc ? b.compareTo(a) : a.compareTo(b);
    }

    final list = List<Job>.of(jobs);
    switch (sort) {
      case JobSort.relevance:
        break;
      case JobSort.newest:
        list.sort((a, b) => compareNullable(a.created, b.created, true));
      case JobSort.oldest:
        list.sort((a, b) => compareNullable(a.created, b.created, false));
      case JobSort.salaryHighToLow:
        list.sort((a, b) => compareNullable(salary(a), salary(b), true));
      case JobSort.salaryLowToHigh:
        list.sort((a, b) => compareNullable(salary(a), salary(b), false));
    }
    return list;
  }

  Future<List<Job>> _fetchCategory(
    JobQuery query,
    CategoryRequest request,
  ) async {
    final uri = _buildUri(query, request);
    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw JobServiceException(
        'The request timed out. Please try again.',
        isNetworkError: true,
      );
    } catch (_) {
      throw JobServiceException(
        'No internet connection. Check your network and retry.',
        isNetworkError: true,
      );
    }

    switch (response.statusCode) {
      case 200:
        return _parse(response.body);
      case 401:
      case 403:
        throw JobServiceException(
          'Adzuna rejected the credentials. Verify your app id and app key.',
        );
      case 429:
        throw JobServiceException(
          'Rate limit reached. Please wait a moment and try again.',
          isRateLimit: true,
        );
      default:
        throw JobServiceException(
          'Adzuna returned an error (${response.statusCode}). Try again later.',
        );
    }
  }

  Uri _buildUri(JobQuery query, CategoryRequest request) {
    final params = <String, String>{
      'app_id': AppConfig.adzunaAppId,
      'app_key': AppConfig.adzunaAppKey,
      'results_per_page': '${AppConfig.resultsPerPage}',
      'content-type': 'application/json',
      'max_days_old': '${AppConfig.maxDaysOld}',
    };

    final keywords = [
      query.keywords.trim(),
      if (query.type == JobType.internship) 'internship',
      if (request.what != null) request.what!,
    ].where((s) => s.isNotEmpty).join(' ');
    if (keywords.isNotEmpty) params['what'] = keywords;
    if (request.whatOr != null) params['what_or'] = request.whatOr!;
    if (query.location.trim().isNotEmpty) {
      params['where'] = query.location.trim();
    }
    final flag = query.type.queryFlag;
    if (flag != null) params[flag] = '1';
    if (request.tag != null) params['category'] = request.tag!;
    if (query.sort != JobSort.relevance) {
      params['sort_by'] = switch (query.sort) {
        JobSort.newest || JobSort.oldest => 'date',
        _ => 'salary',
      };
      if (query.sort == JobSort.salaryLowToHigh) {
        // Skip unsalaried and placeholder (₹0–₹1) postings when ranking upward.
        params['salary_min'] = '10000';
      }
      params['sort_direction'] = switch (query.sort) {
        JobSort.newest || JobSort.salaryHighToLow => 'down',
        _ => 'up',
      };
    }

    return Uri.parse(
      '${AppConfig.baseUrl}/${AppConfig.country}/search/${query.page}',
    ).replace(queryParameters: params);
  }

  List<Job> _parse(String body) {
    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw JobServiceException('Received an unexpected response from Adzuna.');
    }

    final results = decoded['results'];
    if (results is! List) return const [];

    final symbol = _currencyByCountry[AppConfig.country] ?? r'$';
    return results
        .whereType<Map<String, dynamic>>()
        .map((json) => Job.fromAdzuna(json, currencySymbol: symbol))
        .where((job) => job.isOpen)
        .toList();
  }

  void dispose() => _client.close();
}
