import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DualLocationSearchScreen extends StatefulWidget {
  final List<String> allowedPickupCities;
  final String initialPickup;
  final String initialDrop;
  final bool focusDrop;

  const DualLocationSearchScreen({
    super.key,
    this.allowedPickupCities = const [],
    this.initialPickup = '',
    this.initialDrop = '',
    this.focusDrop = false,
  });

  @override
  State<DualLocationSearchScreen> createState() => _DualLocationSearchScreenState();
}

class _DualLocationSearchScreenState extends State<DualLocationSearchScreen> {
  final String apiKey = 'AIzaSyA9WZ75akgvEYdJiPK1UQIpYNhiuStGQhA';
  
  late TextEditingController _pickupController;
  late TextEditingController _dropController;
  
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _dropFocus = FocusNode();
  
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;
  bool _isPickupActive = true;

  Map<String, dynamic>? _selectedPickup;
  Map<String, dynamic>? _selectedDrop;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.initialPickup);
    _dropController = TextEditingController(text: widget.initialDrop);
    _isPickupActive = !widget.focusDrop;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusDrop) {
        _dropFocus.requestFocus();
      } else {
        _pickupFocus.requestFocus();
      }
    });
  }

  Future<void> _searchLocation(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List filtered = (data['predictions'] as List).where((p) {
          if (!_isPickupActive || widget.allowedPickupCities.isEmpty) return true;
          String desc = p['description'].toString().toLowerCase();
          return widget.allowedPickupCities.any((city) => desc.contains(city.toLowerCase()));
        }).toList();

        setState(() {
          _suggestions = filtered.map((p) => {
            'description': p['description'].toString(),
            'placeId': p['place_id'].toString(),
          }).toList();
        });
      } else {
        setState(() => _suggestions = []);
      }
    } catch (e) {
      setState(() => _suggestions = []);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectPlace(String placeId, String description) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final address = data['result']['formatted_address'];

          final selectedData = {
            'lat': location['lat'],
            'lng': location['lng'],
            'address': address,
            'description': description,
          };

          if (_isPickupActive) {
            _selectedPickup = selectedData;
            _pickupController.text = description;
            setState(() {
              _isPickupActive = false;
              _suggestions = [];
            });
            _dropFocus.requestFocus();
          } else {
            _selectedDrop = selectedData;
            _dropController.text = description;
            
            // If both are selected, or we just selected drop and pickup was already there
            _handleFinish();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    setState(() => _isLoading = false);
  }

  void _handleFinish() {
    Navigator.pop(context, {
      'pickup': _selectedPickup,
      'drop': _selectedDrop,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plan Your Trip'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            if (_pickupController.text.isNotEmpty && _dropController.text.isNotEmpty)
              TextButton(
                onPressed: _handleFinish,
                child: const Text('DONE', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              )
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                children: [
                  // Pickup Field
                  TextField(
                    controller: _pickupController,
                    focusNode: _pickupFocus,
                    onTap: () => setState(() {
                      _isPickupActive = true;
                      if (_suggestions.isNotEmpty) _searchLocation(_pickupController.text);
                    }),
                    onChanged: (val) {
                      _isPickupActive = true;
                      _searchLocation(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Pickup location',
                      prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                      suffixIcon: _pickupController.text.isNotEmpty && _isPickupActive
                          ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => _pickupController.clear())
                          : null,
                      filled: true,
                      fillColor: _isPickupActive ? Colors.orange.shade50 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Drop Field
                  TextField(
                    controller: _dropController,
                    focusNode: _dropFocus,
                    onTap: () => setState(() {
                      _isPickupActive = false;
                      if (_suggestions.isNotEmpty) _searchLocation(_dropController.text);
                    }),
                    onChanged: (val) {
                      _isPickupActive = false;
                      _searchLocation(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Drop location',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      suffixIcon: _dropController.text.isNotEmpty && !_isPickupActive
                          ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => _dropController.clear())
                          : null,
                      filled: true,
                      fillColor: !_isPickupActive ? Colors.orange.shade50 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const LinearProgressIndicator(minHeight: 2, color: Colors.blue, backgroundColor: Colors.transparent),
            Expanded(
              child: _suggestions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _isPickupActive ? 'Where from?' : 'Where to?',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _suggestions.length,
                      padding: EdgeInsets.all(10),
                      separatorBuilder: (context, index) => Divider(height: 1,color: Colors.grey.shade300,),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.blue),
                          title: Text(item['description']!),
                          onTap: () => _selectPlace(item['placeId']!, item['description']!),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
