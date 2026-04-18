import 'package:flutter/material.dart';
import '../../../utill/app_constants.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../model/spaces_list_model.dart';

class ViewAllSpaceController with ChangeNotifier {
  SpacesListModel? _viewSpaceListModel;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// 🔹 PAGINATION VARIABLES
  int _page = 1;
  final int _limit = 10;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;

  bool get isFetchingMore => _isFetchingMore;

  /// original SPACES list
  List<Space> _allSpaces = [];
  List<Space> get allSpaces => _allSpaces;

  /// filtered list (UI uses this)
  List<Space> _filteredSpaces = [];
  List<Space> get filteredSpaces => _filteredSpaces;

  /// search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// filters from API
  Filters? filters;

  /// dynamic price range from API
  double minPrice = 0;
  double maxPrice = 0;

  Set<int> selectedStars = {};

  /// active filters
  RangeValues priceRange = const RangeValues(0, 0);
  Set<String> selectedLocations = {};
  List<String> selectedTerms = [];

  /// ================= FETCH SPACES =================
  Future<void> fetchAllSpaces({
    int? locationId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? rooms,
    int? adults,
    int? children,
    bool loadMore = false,
  }) async {

    if (_isFetchingMore || !_hasMoreData) return;

    if (loadMore) {
      _isFetchingMore = true;
      notifyListeners();
    } else {
      _page = 1;
      _hasMoreData = true;
      _allSpaces.clear();
      _filteredSpaces.clear();
      _setLoading(true);
    }

    try {
      String url =
          "${AppConstants.hotelSpacesUrl}?page=$_page&limit=$_limit";

      final response =
      await HttpService().getApi(url, isOtherDomain: true);

      if (response != null) {
        _viewSpaceListModel = SpacesListModel.fromJson(response);

        final List<Space> newSpaces =
            _viewSpaceListModel?.data?.spaces ?? [];

        if (newSpaces.isNotEmpty) {
          _allSpaces.addAll(newSpaces);
          _page++;
        } else {
          _hasMoreData = false;
        }

        filters = _viewSpaceListModel?.data?.filters;

        /// ✅ SAFE PRICE RANGE SET
        if (!loadMore &&
            filters?.priceRange != null &&
            filters!.priceRange!.length == 2) {

          final newMin =
              double.tryParse(filters!.priceRange![0]) ?? 0;

          final newMax =
              double.tryParse(filters!.priceRange![1]) ?? 0;

          if (newMin <= newMax) {
            minPrice = newMin;
            maxPrice = newMax;
          } else {
            minPrice = 0;
            maxPrice = 0;
          }

          priceRange = RangeValues(minPrice, maxPrice);
        }

        _applyAllFilters();
      }
    } catch (e) {
      debugPrint("SPACES API error: $e");
    }

    _isFetchingMore = false;
    _setLoading(false);
  }

  /// ================= SEARCH =================
  void searchHotels(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyAllFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyAllFilters();
  }

  /// ================= APPLY ALL FILTERS =================
  void _applyAllFilters() {
    List<Space> list = List.from(_allSpaces);

    /// ✅ PRICE FILTER (CRASH SAFE)
    if (minPrice != 0 || maxPrice != 0) {

      final safeStart =
      priceRange.start.clamp(minPrice, maxPrice);

      final safeEnd =
      priceRange.end.clamp(minPrice, maxPrice);

      list = list.where((spaces) {
        final price =
            double.tryParse(spaces.price ?? '0') ?? 0;

        return price >= safeStart &&
            price <= safeEnd;
      }).toList();
    }

    /// LOCATION FILTER
    if (selectedLocations.isNotEmpty) {
      list = list.where((spaces) {
        return selectedLocations
            .contains(spaces.location?.name);
      }).toList();
    }

    /// STAR FILTER
    if (selectedStars.isNotEmpty) {
      list = list.where((spaces) {
        final stars = spaces.reviewScore;
        return selectedStars.contains(stars);
      }).toList();
    }

    /// SEARCH FILTER
    if (_searchQuery.isNotEmpty) {
      list = list.where((hotel) {
        final name = hotel.title?.toLowerCase() ?? '';
        final address = hotel.address?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
            address.contains(_searchQuery);
      }).toList();
    }

    _filteredSpaces = list;
    notifyListeners();
  }

  /// ================= FILTER ACTIONS =================
  void applyFilters() {
    _applyAllFilters();
  }

  void clearFilters() {
    priceRange = RangeValues(minPrice, maxPrice);
    selectedLocations.clear();
    selectedStars.clear();
    selectedTerms.clear();
    _searchQuery = '';
    _filteredSpaces = List.from(_allSpaces);
    notifyListeners();
  }

  /// ✅ SAFE PRICE RANGE UPDATE METHOD
  void updatePriceRange(RangeValues values) {
    final safeStart =
    values.start.clamp(minPrice, maxPrice);
    final safeEnd =
    values.end.clamp(minPrice, maxPrice);

    priceRange = RangeValues(safeStart, safeEnd);
    _applyAllFilters();
  }

  /// ================= LOADING =================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
