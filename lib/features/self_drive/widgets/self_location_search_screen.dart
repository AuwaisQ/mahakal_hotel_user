import 'package:flutter/material.dart';
import '../self_form_screen.dart'; // To access SelfLoaction class

class SelfLocationSearchScreen extends StatefulWidget {
  final List<SelfLoaction> locations;
  final String hintText;

  const SelfLocationSearchScreen({
    super.key,
    required this.locations,
    this.hintText = 'Search location',
  });

  @override
  State<SelfLocationSearchScreen> createState() => _SelfLocationSearchScreenState();
}

class _SelfLocationSearchScreenState extends State<SelfLocationSearchScreen> {
  late List<SelfLoaction> _filteredList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredList = widget.locations;
  }

  void _filterLocations(String query) {
    setState(() {
      _filteredList = widget.locations
          .where((e) => (e.city ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
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
                onChanged: _filterLocations,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLocations('');
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
            child: _filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No locations found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.separated(
              padding: EdgeInsets.all(10),
                    itemCount: _filteredList.length,
                    separatorBuilder: (context, index) => Divider(height: 1,color: Colors.grey.shade300,),
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.blue),
                        title: Text(item.city ?? ''),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ));
  }
}
