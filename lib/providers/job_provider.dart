import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/job.dart';
import '../models/job_filter.dart';
import '../services/job_service.dart';

enum JobStatus { initial, loading, refreshing, success, empty, error }

/// Owns the job list state: search keywords, active filter and load status.
class JobProvider extends ChangeNotifier {
  JobProvider(this._service);

  final JobService _service;

  JobQuery _query = const JobQuery();
  JobStatus _status = JobStatus.initial;
  List<Job> _jobs = const [];
  String? _errorMessage;
  Timer? _debounce;

  JobQuery get query => _query;
  JobStatus get status => _status;
  List<Job> get jobs => _jobs;
  String? get errorMessage => _errorMessage;
  JobType get selectedType => _query.type;
  JobCategory get selectedCategory => _query.category;
  String get location => _query.location;
  String get keywords => _query.keywords;
  JobSort get sort => _query.sort;

  bool get isBusy =>
      _status == JobStatus.loading || _status == JobStatus.refreshing;

  Future<void> load({bool refresh = false}) async {
    _status = refresh ? JobStatus.refreshing : JobStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final requested = _query;
    try {
      final result = await _service.fetchJobs(requested);
      if (!identical(requested, _query)) {
        return; // A newer request superseded this one.
      }
      _jobs = result;
      _status = result.isEmpty ? JobStatus.empty : JobStatus.success;
    } on JobServiceException catch (e) {
      _errorMessage = e.message;
      _status = JobStatus.error;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading jobs.';
      _status = JobStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load(refresh: true);

  /// Debounced free-text search.
  void search(String keywords) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (keywords.trim() == _query.keywords) return;
      _query = _query.copyWith(keywords: keywords.trim(), page: 1);
      load();
    });
  }

  void submitSearch(String keywords) {
    _debounce?.cancel();
    _query = _query.copyWith(keywords: keywords.trim(), page: 1);
    load();
  }

  void selectType(JobType type) {
    if (type == _query.type) return;
    _query = _query.copyWith(type: type, page: 1);
    load();
  }

  void selectCategory(JobCategory category) {
    if (category == _query.category) return;
    _query = _query.copyWith(category: category, page: 1);
    load();
  }

  void selectSort(JobSort sort) {
    if (sort == _query.sort) return;
    _query = _query.copyWith(sort: sort, page: 1);
    load();
  }

  /// Restricts results to an Indian city; pass an empty string for all India.
  void selectLocation(String location) {
    if (location == _query.location) return;
    _query = _query.copyWith(location: location, page: 1);
    load();
  }

  void clearSearch() {
    _debounce?.cancel();
    if (_query.keywords.isEmpty) return;
    _query = _query.copyWith(keywords: '', page: 1);
    load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
