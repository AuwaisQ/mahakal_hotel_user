import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/activities_list_model.dart';

class ActivitiesListController with ChangeNotifier {
  ActivitiesListModel? _activitiesListModel;
  ActivitiesListModel? get activitiesListModel => _activitiesListModel;

  List<Datum> _allActivities = [];
  List<Datum> get allActivities => _allActivities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // Pagination variables
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  // Filter variables
  List<String> _selectedPrices = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedCategoryIds = [];
  String _selectedCity = '';

  Future<void> getActivitiesList({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    // If loading more, check if we have more pages
    if (isLoadMore) {
      if (_isLoadingMore || !_hasMorePages) return;
      _isLoadingMore = true;
      notifyListeners();
    } else {
      if (isRefresh) {
        _resetPagination();
      }
      _setLoading(true);
    }

    try {
      Map<String, dynamic> data = {
        "price": _selectedPrices,
        "language": _selectedLanguages,
        "category_id": _selectedCategoryIds,
        "city": _selectedCity
      };

      // FIX: Only add city if it's not empty
      if (_selectedCity.isNotEmpty) {
        data["city"] = _selectedCity;
      }

      String url = "${AppConstants.activityListUrl}$_currentPage";

      print("Activity List URL: $url");
      print("Request Data: $data"); // Add this to debug

      final res = await HttpService().postApi(url, data);

      if (res != null) {
        _activitiesListModel = ActivitiesListModel.fromJson(res);

        // Update pagination info
        final pagination = _activitiesListModel?.pagination;
        if (pagination != null) {
          _currentPage = pagination.currentPage;
          _totalPages = pagination.lastPage;
          _totalItems = pagination.total;

          // Check if there are more pages
          _hasMorePages = pagination.currentPage < pagination.lastPage;
        }

        final newActivities = _activitiesListModel?.data ?? [];

        if (isLoadMore) {
          // Append new activities for load more
          _allActivities.addAll(newActivities);
        } else {
          // Initial load or refresh
          _allActivities = newActivities;
        }

        if (isLoadMore) {
          _isLoadingMore = false;
        } else {
          _setLoading(false);
        }

        notifyListeners();
      } else {
        _handleError(isLoadMore);
      }
    } catch (e) {
      print("Error in getActivitiesList: $e");
      _handleError(isLoadMore);
    }
  }

  // Load next page
  Future<void> loadMoreActivities() async {
    if (!_hasMorePages || _isLoading || _isLoadingMore) return;

    _currentPage++;
    await getActivitiesList(isLoadMore: true);
  }

  // Refresh data
  Future<void> refreshActivities() async {
    await getActivitiesList(isRefresh: true);
  }

  // Apply filters and refresh
  Future<void> applyFilters({
    List<String>? prices,
    List<String>? languages,
    List<String>? categoryIds,
    String? city,
  }) async {
    if (prices != null) _selectedPrices = prices;
    if (languages != null) _selectedLanguages = languages;
    if (categoryIds != null) _selectedCategoryIds = categoryIds;

    // FIX: Properly handle city filter
    if (city == null) {
      _selectedCity = ''; // Clear city filter
    } else if (city.isEmpty) {
      _selectedCity = ''; // Also clear for empty string
    } else {
      _selectedCity = city; // Set actual city
    }

    _resetPagination();
    await getActivitiesList(isRefresh: true);

    print("Applied Filters - City: '$_selectedCity', Categories: $_selectedCategoryIds");
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedPrices = [];
    _selectedLanguages = [];
    _selectedCategoryIds = [];
    _selectedCity = '';

    _resetPagination();
    await getActivitiesList(isRefresh: true);
  }

  // Reset pagination
  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _allActivities.clear();
  }

  // Error handling
  void _handleError(bool isLoadMore) {
    if (isLoadMore) {
      // If load more fails, go back one page
      _currentPage = _currentPage > 1 ? _currentPage - 1 : 1;
      _isLoadingMore = false;
    } else {
      _setLoading(false);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Getters for current filter state
  List<String> get selectedPrices => List.from(_selectedPrices);
  List<String> get selectedLanguages => List.from(_selectedLanguages);
  List<String> get selectedCategoryIds => List.from(_selectedCategoryIds);
  String get selectedCity => _selectedCity;
}