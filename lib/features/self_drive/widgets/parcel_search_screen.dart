import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../instanthome_page.dart';

class ParcelSearchScreen extends StatefulWidget {
  final List<RecentLocation> recentList;
  final String hintText;

  const ParcelSearchScreen({
    super.key,
    required this.recentList,
    this.hintText = 'Drop location',
  });

  @override
  State<ParcelSearchScreen> createState() => _ParcelSearchScreenState();
}

class _ParcelSearchScreenState extends State<ParcelSearchScreen> {
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
        setState(() {
          _suggestions = (data['predictions'] as List).map((p) => {
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
    return Scaffold(
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
              autofocus: true,
              onChanged: _searchLocation,
              decoration: InputDecoration(
                hintText: 'Search drop address',
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
          
          if (_searchController.text.isEmpty) ...[
            // ACTION BUTTONS (Select on Map, etc)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: const Text('Select on map'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add stops'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Locations', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 10),
          ],

          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildRecentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_suggestions.isEmpty && !_isLoading) {
      return const Center(child: Text('No results found'));
    }
    return ListView.separated(
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
    );
  }

  Widget _buildRecentList() {
    if (widget.recentList.isEmpty) {
      return const Center(child: Text('No recent locations'));
    }
    return ListView.separated(
      itemCount: widget.recentList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = widget.recentList[index];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.orange),
          title: Text(item.address),
          subtitle: const Text('Recent location'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.pop(context, {
              'lat': item.lat,
              'lng': item.lng,
              'address': item.address,
              'description': item.address,
            });
          },
        );
      },
    );
  }
}
