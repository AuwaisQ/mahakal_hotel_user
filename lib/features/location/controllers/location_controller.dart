import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/model/api_response.dart';
import 'package:mahakal/features/location/domain/models/place_details_model.dart';
import 'package:mahakal/features/location/domain/models/prediction_model.dart';
import 'package:mahakal/features/location/domain/services/location_service_interface.dart';
import 'package:mahakal/helper/api_checker.dart';
import 'package:mahakal/main.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController with ChangeNotifier {
  final LocationServiceInterface locationServiceInterface;
  LocationController({required this.locationServiceInterface});

  Position _position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );
  Position _pickPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1);
  bool _loading = false;
  bool get loading => _loading;
  bool _isBilling = true;
  bool get isBilling => _isBilling;
  final TextEditingController _locationController = TextEditingController();

  String? _postalCode;
  String? get postalCode => _postalCode;
  String? _city;
  String? get city => _city;
  String? _state;
  String? get state => _state;
  String? _country;
  String? get country => _country;
  String? _countryCode;
  String? get countryCode => _countryCode;
  bool _isLoadingLocation = false;

  Position get position => _position;
  Position get pickPosition => _pickPosition;
  Placemark _address = const Placemark();
  Placemark? _pickAddress = const Placemark();

  Placemark get address => _address;
  Placemark? get pickAddress => _pickAddress;

  TextEditingController get locationController => _locationController;

  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController? _mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;

  bool get buttonDisabled => _buttonDisabled;
  GoogleMapController? get mapController => _mapController;


  void setLocationController(String text) {
    _locationController.text = text;
  }

  Future<void> getCurrentLocation(BuildContext context, bool fromAddress,
      {GoogleMapController? mapController}) async {
    if (_isLoadingLocation) return;
    _isLoadingLocation = true;
    _loading = true;
    notifyListeners();

    Position? myPosition;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          // 1. Try instant cached position first (0ms latency, zero battery/CPU)
          try {
            myPosition = await Geolocator.getLastKnownPosition();
          } catch (e) {
            if (kDebugMode) {
              print('Cached position error: $e');
            }
          }

          // 2. Fallback to fresh position with low accuracy (triangulation, fast) and short timeout
          if (myPosition == null) {
            try {
              myPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                timeLimit: const Duration(seconds: 3),
              );
            } catch (e) {
              if (kDebugMode) {
                print('Fresh GPS location error or timeout: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }

    if (myPosition != null &&
        myPosition.latitude != 0 &&
        myPosition.longitude != 0) {
      if (fromAddress) {
        _position = myPosition;
      } else {
        _pickPosition = myPosition;
      }

      if (mapController != null) {
        try {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(myPosition.latitude, myPosition.longitude),
                zoom: 17),
          ));
        } catch (_) {}
      }

      try {
        final ctx = Get.context ?? context;
        String address = await getAddressFromGeocode(
            LatLng(myPosition.latitude, myPosition.longitude), ctx);
        Placemark myPlaceMark = Placemark(
          name: address,
          locality: _city ?? '',
          postalCode: _postalCode ?? '',
          country: _country ?? 'India',
          administrativeArea: _state ?? '',
        );
        fromAddress ? _address = myPlaceMark : _pickAddress = myPlaceMark;
        if (fromAddress && address.isNotEmpty) {
          _locationController.text = address;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating address model: $e');
        }
      }
    }

    _loading = false;
    _isLoadingLocation = false;
    notifyListeners();
  }

  Future<void> updateMapPosition(CameraPosition? position, bool fromAddress, String? address, BuildContext context) async {
    if (_updateAddAddressData) {
      _loading = true;
      // notifyListeners();
      try {
        if (fromAddress) {
          _position = Position(
              latitude: position!.target.latitude,
              longitude: position.target.longitude,
              timestamp: DateTime.now(),
              heading: 1,
              accuracy: 1,
              altitude: 1,
              speedAccuracy: 1,
              speed: 1,
              altitudeAccuracy: 1,
              headingAccuracy: 1);
        } else {
          _pickPosition = Position(
              latitude: position!.target.latitude,
              longitude: position.target.longitude,
              timestamp: DateTime.now(),
              heading: 1,
              accuracy: 1,
              altitude: 1,
              speedAccuracy: 1,
              speed: 1,
              altitudeAccuracy: 1,
              headingAccuracy: 1);
        }

        //  ADD THIS LINE (Postal Code Call)
        await getPostalCodeFromLatLng(LatLng(position.target.latitude, position.target.longitude));

        if (_changeAddress) {
          String? addresss = await getAddressFromGeocode(
              LatLng(position.target.latitude, position.target.longitude),
              context);
          fromAddress
              ? _address = Placemark(name: addresss)
              : _pickAddress = Placemark(name: addresss);

          if (address != null) {
            _locationController.text = address;
          } else if (fromAddress) {
            _locationController.text = placeMarkToAddress(_address);
          }
        } else {
          _changeAddress = true;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      _loading = false;
      notifyListeners();
    } else {
      _updateAddAddressData = true;
    }
  }

  Future<void> setLocation(String? placeID, String? address,
      GoogleMapController? mapController) async {
    _loading = true;
    notifyListeners();
    PlaceDetailsModel detail;
    ApiResponse response =
    await locationServiceInterface.getPlaceDetails(placeID);
    detail = PlaceDetailsModel.fromJson(response.response!.data);

    _pickPosition = Position(
        longitude: detail.result?.geometry?.location?.lat ?? 0,
        latitude: detail.result?.geometry?.location?.lng ?? 0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1);

    _pickAddress = Placemark(name: address);
    _changeAddress = false;

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(detail.result?.geometry?.location?.lat ?? 0,
              detail.result?.geometry?.location?.lng ?? 0),
          zoom: 16)));
    }
    _loading = false;
    notifyListeners();
  }

  void disableButton() {
    _buttonDisabled = true;
    notifyListeners();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    if (_pickAddress != null) {
      _address = _pickAddress!;
      _locationController.text = placeMarkToAddress(_address);
    }
    _updateAddAddressData = false;
    notifyListeners();
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
    _locationController.text = placeMarkToAddress(_address);
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(
      LatLng latLng, BuildContext context) async {
    String address = '';
    try {
      ApiResponse response =
      await locationServiceInterface.getAddressFromGeocode(latLng);
      if (response.response != null &&
          response.response!.statusCode == 200 &&
          response.response!.data['status'] == 'OK' &&
          response.response!.data['results'] != null &&
          (response.response!.data['results'] as List).isNotEmpty) {
        final result = response.response!.data['results'][0];
        address = result['formatted_address']?.toString() ?? '';

        // Extract structured components from Google Geocoding response
        if (result['address_components'] != null) {
          final components = result['address_components'] as List;
          for (var comp in components) {
            final types = (comp['types'] as List?)
                ?.map((t) => t.toString())
                .toList() ??
                [];
            final longName = comp['long_name']?.toString() ?? '';
            final shortName = comp['short_name']?.toString() ?? '';

            if (types.contains('postal_code')) {
              _postalCode = longName;
            } else if (types.contains('locality')) {
              _city = longName;
            } else if (_city == null &&
                (types.contains('administrative_area_level_2') ||
                    types.contains('sublocality_level_1') ||
                    types.contains('sublocality'))) {
              _city = longName;
            } else if (types.contains('administrative_area_level_1')) {
              _state = longName;
            } else if (types.contains('country')) {
              _country = longName;
              _countryCode = shortName;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address from geocode API: $e');
      }
    }

    return address;
  }

  Future<List<PredictionModel>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      ApiResponse response =
      await locationServiceInterface.searchLocation(text);
      if (response.response!.statusCode == 200 &&
          response.response!.data['status'] == 'OK') {
        _predictionList = [];
        response.response!.data['predictions'].forEach((prediction) =>
            _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        ApiChecker.checkApi(response);
      }
    }
    return _predictionList;
  }

  String placeMarkToAddress(Placemark placeMark) {
    return '${placeMark.name ?? ''} ${placeMark.subAdministrativeArea ?? ''} ${placeMark.isoCountryCode ?? ''}';
  }

  void isBillingChanged(bool change) {
    _isBilling = change;
    if (change) {
      change = !_isBilling;
    }
    notifyListeners();
  }

  //Get Postal Code from LatLng
  Future<void> getPostalCodeFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        _postalCode = placemarks.first.postalCode;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting postal code: $e");
      }
    }
  }

}
