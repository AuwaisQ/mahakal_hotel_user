import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utill/app_constants.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../model/view_allhotel_model.dart';

class ViewAllHotelController with ChangeNotifier {

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // Pagination properties
  int _currentPage = 1;
  int get currentPage => _currentPage;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  Pagination? _pagination;
  Pagination? get pagination => _pagination;

  /// original hotel list
  List<AllHotel> _allHotels = [];
  List<AllHotel> get allHotels => _allHotels; // Getter for debug

  /// filtered list (UI uses this)
  List<AllHotel> _filteredHotels = [];
  List<AllHotel> get filteredHotels => _filteredHotels;

  /// search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// filters from API
  Filters? filters;

  /// dynamic price range from API
  double minPrice = 0;
  double maxPrice = 10000; // Default max price

  Set<int> selectedStars = {};

  /// active filters
  RangeValues priceRange = const RangeValues(0, 0);
  Set<String> selectedLocations = {};
  List<String> selectedTerms = [];

  // Search parameters (store for pagination)
  int? _lastLocationId;
  DateTime? _lastCheckInDate;
  DateTime? _lastCheckOutDate;
  int? _lastRooms;
  int? _lastAdults;
  int? _lastChildren;
  bool _lastIsDestination = false;

  // Constructor - initialize price range
  ViewAllHotelController() {
    // Initialize with reasonable defaults
    _initializeDefaultPriceRange();
  }

  void _initializeDefaultPriceRange() {
    minPrice = 0;
    maxPrice = 10000; // Reasonable default for hotel prices
    priceRange = RangeValues(minPrice, maxPrice);
    print("💰 Initialized default price range: $minPrice - $maxPrice");
  }

  Future<void> fetchAllHotels({
    int? locationId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? rooms,
    int? adults,
    int? children,
    bool isDestination = false,
    bool loadMore = false,
  }) async {
    // If loading more, check conditions
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      print("🔄 Loading more hotels, page $_currentPage");
    } else {
      _setLoading(true);

      // Reset pagination on fresh load
      _currentPage = 1;
      _allHotels.clear();
      _filteredHotels.clear();
      _hasMore = true;

      print("🔄 Initial load, starting from page 1");

      // Store search parameters
      _lastLocationId = locationId;
      _lastCheckInDate = checkInDate;
      _lastCheckOutDate = checkOutDate;
      _lastRooms = rooms;
      _lastAdults = adults;
      _lastChildren = children;
      _lastIsDestination = isDestination;
    }

    notifyListeners();

    try {
      String url = isDestination
          ? AppConstants.hotelPapulerUrl + locationId.toString()
          : AppConstants.allHotelsUrl;

      // Build URL with parameters
      final Map<String, dynamic> queryParams = {};

      // Always add pagination
      queryParams['page'] = _currentPage;
      queryParams['per_page'] = 10;

      // Add search params if they exist
      if (locationId != null && checkInDate != null && checkOutDate != null) {
        final formatter = DateFormat('dd/MM/yyyy');

        queryParams['location_id'] = locationId;
        queryParams['start'] = formatter.format(checkInDate);
        queryParams['end'] = formatter.format(checkOutDate);
        queryParams['room'] = rooms ?? 1;
        queryParams['adults'] = adults ?? 1;
        queryParams['children'] = children ?? 0;
      }

      // Construct final URL
      String finalUrl = url;
      if (queryParams.isNotEmpty) {
        finalUrl += '?';
        queryParams.forEach((key, value) {
          if (value != null) {
            finalUrl += '$key=$value&';
          }
        });
        finalUrl = finalUrl.substring(0, finalUrl.length - 1); // Remove last '&'
      }

      print("📡 Fetching URL: $finalUrl");

      final response = await HttpService().getApi(finalUrl, isOtherDomain: true);

      if (response != null && response['status'] == true) {
        print(" API Response received successfully");

        final viewHotelModel = ViewAllHotelModel.fromJson(response);

        // Store filters from API response
        filters = viewHotelModel.data?.filters;

        // IMPORTANT: Extract price range from API if available
        if (filters?.priceRange != null && filters!.priceRange!.length >= 2) {
          final minPriceStr = filters!.priceRange![0];
          final maxPriceStr = filters!.priceRange![1];

          minPrice = double.tryParse(minPriceStr) ?? 0;
          maxPrice = double.tryParse(maxPriceStr) ?? 10000;

          // Update price range with actual values from API
          if (minPrice > 0 || maxPrice > 0) {
            priceRange = RangeValues(minPrice, maxPrice);
            print("💰 Price range updated from API: $minPrice - $maxPrice");
          }
        } else {
          print("⚠️ No price range in API response, using defaults");
        }

        // Store pagination info
        if (viewHotelModel.data?.pagination != null) {
          _pagination = viewHotelModel.data!.pagination;

          // Calculate hasMore correctly
          _hasMore = _pagination!.currentPage < _pagination!.lastPage;

          print("📊 Pagination: Page ${_pagination!.currentPage} of ${_pagination!.lastPage}");
          print("📊 Total hotels: ${_pagination!.total}");
          print("📊 Has more pages: $_hasMore");
        } else {
          print("⚠️ No pagination in API response");
          _hasMore = false;
        }

        // Add new hotels to list
        final newHotels = viewHotelModel.data?.hotels ?? [];
        print("🏨 Received ${newHotels.length} hotels from API");

        // Print first hotel details for debugging
        if (newHotels.isNotEmpty) {
          final firstHotel = newHotels.first;
          print("🏨 Sample hotel: ${firstHotel.title}, Price: ${firstHotel.price}");
        }

        if (loadMore && newHotels.isNotEmpty) {
          final existingIds = _allHotels.map((e) => e.id).toSet();
          final newUniqueHotels =
          newHotels.where((h) => !existingIds.contains(h.id)).toList();

          if (newUniqueHotels.isEmpty) {
            print("🛑 No new unique hotels, stopping pagination");
            _hasMore = false;
            return;
          }

          _allHotels.addAll(newUniqueHotels);
        } else {
          _allHotels.addAll(newHotels);
        }

        //_allHotels.addAll(newHotels);

        print("🏨 Total hotels in memory: ${_allHotels.length}");

        // Apply filters to show hotels
         _applyAllFilters();

        // Prepare for next page if needed
        if (_hasMore && !loadMore) {
          _currentPage++;
          print("📈 Next page will be: $_currentPage");
        }

      } else {
        print("❌ API response failed or no data");
        _hasMore = false;
      }
    } catch (e) {
      print("❌ Hotel API error: $e");
      _hasMore = false;
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        _setLoading(false);
      }
      notifyListeners();
    }
  }

  /// Load more hotels
  Future<void> loadMoreHotels() async {
    print("🔄 loadMoreHotels called");
    print("   - Current state: isLoading=$_isLoading, isLoadingMore=$_isLoadingMore, hasMore=$_hasMore");
    print("   - Current page: $_currentPage");

    if (_isLoading || _isLoadingMore || !_hasMore) {
      print("⏸️ Cannot load more - conditions not met");
      return;
    }

    await fetchAllHotels(
      locationId: _lastLocationId,
      checkInDate: _lastCheckInDate,
      checkOutDate: _lastCheckOutDate,
      rooms: _lastRooms,
      adults: _lastAdults,
      children: _lastChildren,
      isDestination: _lastIsDestination,
      loadMore: true,
    );
  }

  /// Refresh hotels (pull to refresh)
  Future<void> refreshHotels() async {
    print("🔄 Refreshing hotels");
    await fetchAllHotels(
      locationId: _lastLocationId,
      checkInDate: _lastCheckInDate,
      checkOutDate: _lastCheckOutDate,
      rooms: _lastRooms,
      adults: _lastAdults,
      children: _lastChildren,
      isDestination: _lastIsDestination,
      loadMore: false,
    );
  }

  /// SEARCH HOTELS
  void searchHotels(String query) {
    print("🔍 Searching for: '$query'");
    _searchQuery = query.toLowerCase().trim();

    // Apply filters immediately for local search
    _applyAllFilters();

    // Note: If you want to search from API, you'd need to reset and fetch
    // For now, we're doing local search only
  }

  /// APPLY ALL FILTERS INCLUDING SEARCH - FIXED VERSION
  void _applyAllFilters() {
    print("🔍 Starting filter process...");
    print("   - Total hotels available: ${_allHotels.length}");

    // Start with all hotels
    List<AllHotel> list = List.from(_allHotels);

    print("   - Price range: ${priceRange.start} - ${priceRange.end}");
    print("   - Search query: '$_searchQuery'");

    // DEBUG: Show all hotel prices
    print("   - Hotel prices:");
    for (var hotel in list) {
      final price = double.tryParse(hotel.price ?? '0') ?? 0;
      print("     • ${hotel.title}: ₹$price");
    }

    /// 1. PRICE FILTER - Fixed logic
    // Only apply price filter if we have valid price range
    if (priceRange.end > priceRange.start && priceRange.end > 0) {
      final originalCount = list.length;
      list = list.where((hotel) {
        final price = double.tryParse(hotel.price ?? '0') ?? 0;
        final inRange = price >= priceRange.start && price <= priceRange.end;
        if (!inRange) {
          print("   ❌ Price filter: '${hotel.title}' (₹$price) out of range");
        }
        return inRange;
      }).toList();
      print("   - After price filter: ${list.length} of $originalCount hotels");
    } else {
      print("   - Skipping price filter (invalid range: ${priceRange.start}-${priceRange.end})");
    }

    /// 2. LOCATION FILTER
    if (selectedLocations.isNotEmpty) {
      final originalCount = list.length;
      list = list.where((hotel) {
        final hasLocation = selectedLocations.contains(hotel.location?.name);
        return hasLocation;
      }).toList();
      print("   - After location filter: ${list.length} of $originalCount hotels");
    }

    /// 3. STAR RATING FILTER
    if (selectedStars.isNotEmpty) {
      final originalCount = list.length;
      list = list.where((hotel) {
        final hotelStars = hotel.starRate?.toInt() ?? 0;
        final hasStar = selectedStars.contains(hotelStars);
        return hasStar;
      }).toList();
      print("   - After star filter: ${list.length} of $originalCount hotels");
    }

    /// 4. ATTRIBUTE FILTER
    if (selectedTerms.isNotEmpty) {
      final originalCount = list.length;
      list = list.where((hotel) {
        final hasTerm = hotel.termsByAttributeInListingPage.any(
              (term) => selectedTerms.contains(term.name),
        );
        return hasTerm;
      }).toList();
      print("   - After attribute filter: ${list.length} of $originalCount hotels");
    }

    /// 5. SEARCH FILTER (Name or Address) - Local search
    if (_searchQuery.isNotEmpty) {
      final originalCount = list.length;
      list = list.where((hotel) {
        final hotelName = hotel.title?.toLowerCase() ?? '';
        final hotelAddress = hotel.address?.toLowerCase() ?? '';
        final matchesSearch = hotelName.contains(_searchQuery) ||
            hotelAddress.contains(_searchQuery);
        if (matchesSearch) {
          print("   ✅ Search match: '${hotel.title}'");
        }
        return matchesSearch;
      }).toList();
      print("   - After search filter: ${list.length} of $originalCount hotels");
    }

    _filteredHotels = list;
    print("✅ Final result: ${_filteredHotels.length} hotels after filtering");

    // Show filtered hotel names
    if (_filteredHotels.isNotEmpty) {
      print("✅ Filtered hotels:");
      for (var hotel in _filteredHotels.take(3)) { // Show first 3
        print("   • ${hotel.title} (₹${hotel.price})");
      }
      if (_filteredHotels.length > 3) {
        print("   ... and ${_filteredHotels.length - 3} more");
      }
    }

    notifyListeners();
  }

  /// Apply filters from UI (reset and fetch with filters)
  void applyFilters() {
    print("🔧 Applying filters and resetting data");

    // Reset pagination
    _currentPage = 1;
    _allHotels.clear();
    _filteredHotels.clear();
    _hasMore = true;

    // Fetch with current parameters
    _fetchHotelsWithCurrentParams();
  }

  /// Clear all filters
  void clearFilters() {
    print("🧹 Clearing all filters");

    // Reset to default price range
    priceRange = RangeValues(minPrice, maxPrice);
    selectedLocations.clear();
    selectedStars.clear();
    selectedTerms.clear();
    _searchQuery = '';

    // Re-apply filters to show all hotels
    _applyAllFilters();
  }

  /// Fetch hotels with current stored parameters
  Future<void> _fetchHotelsWithCurrentParams() async {
    await fetchAllHotels(
      locationId: _lastLocationId,
      checkInDate: _lastCheckInDate,
      checkOutDate: _lastCheckOutDate,
      rooms: _lastRooms,
      adults: _lastAdults,
      children: _lastChildren,
      isDestination: _lastIsDestination,
      loadMore: false,
    );
  }

  /// Clear search only
  void clearSearch() {
    print("❌ Clearing search");
    _searchQuery = '';
    _applyAllFilters();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Update price range from UI slider
  void updatePriceRange(RangeValues newRange) {
    priceRange = newRange;
    print("💰 Price range updated to: ${priceRange.start} - ${priceRange.end}");
    _applyAllFilters();
  }

  /// Toggle star rating filter
  void toggleStarFilter(int star) {
    if (selectedStars.contains(star)) {
      selectedStars.remove(star);
    } else {
      selectedStars.add(star);
    }
    print("⭐ Star filter updated: $selectedStars");
    _applyAllFilters();
  }

  /// Toggle location filter
  void toggleLocationFilter(String location) {
    if (selectedLocations.contains(location)) {
      selectedLocations.remove(location);
    } else {
      selectedLocations.add(location);
    }
    print("📍 Location filter updated: $selectedLocations");
    _applyAllFilters();
  }

  /// Toggle attribute filter
  void toggleAttributeFilter(String term) {
    if (selectedTerms.contains(term)) {
      selectedTerms.remove(term);
    } else {
      selectedTerms.add(term);
    }
    print("🏷️ Attribute filter updated: $selectedTerms");
    _applyAllFilters();
  }
}