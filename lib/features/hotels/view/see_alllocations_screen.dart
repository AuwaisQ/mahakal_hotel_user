import 'package:flutter/material.dart';
import 'package:mahakal/features/hotels/view/view_allhotel_page.dart';
import '../model/hotel_location_model.dart';
import 'hotels_home_page.dart';

class SeeAllLocationsScreen extends StatelessWidget {
  final List<HotelLocation> destinations;

  const SeeAllLocationsScreen({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Populer Locations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        centerTitle: false,
        elevation: 0,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 0.87,
        ),
        itemCount: destinations.length,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AllHotelsScreen(locationId: destination.id,isDestination:true)));
            },
            child: DestinationCard(
              destination: destination.name,
              imageUrl: destination.image,
            ),
          );
        },
      ),
    );
  }
}
