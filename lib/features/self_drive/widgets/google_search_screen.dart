import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoogleSearchScreen extends StatefulWidget {
  final List<String> allowedCities;
  final String hintText;

  const GoogleSearchScreen({
    super.key,
    this.allowedCities = const [],
    this.hintText = 'Search location',
  });

  @override
  State<GoogleSearchScreen> createState() => _GoogleSearchScreenState();
}

class _GoogleSearchScreenState extends State<GoogleSearchScreen> {
  final String apiKey = 'AIzaSyA9WZ75akgvEYdJiPK1UQIpYNhiuStGQhA';
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
          if (widget.allowedCities.isEmpty) return true;
          String desc = p['description'].toString().toLowerCase();
          return widget.allowedCities.any((city) => desc.contains(city.toLowerCase()));
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

          Navigator.pop(context, {
            'lat': location['lat'],
            'lng': location['lng'],
            'address': address,
            'description': description,
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    setState(() => _isLoading = false);
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
          title: Text(widget.hintText),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _searchLocation,
                decoration: InputDecoration(
                  hintText: 'Search city, area or landmark',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchLocation('');
                            },
                          )
                        : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _suggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty ? 'Search for a location' : 'No results found',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
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
    )
    );
  }
}
