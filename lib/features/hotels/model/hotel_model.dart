class Hotel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final double price;
  final String imageUrl;
  final List<String> amenities;
  final double distance;
  final int stars;
  final bool isFeatured;
  final double? discount;
  final String description;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
    required this.amenities,
    required this.distance,
    required this.stars,
    this.isFeatured = false,
    this.discount,
    required this.description,
  });
}

class Room {
  final String id;
  final String hotelId;
  final String type;
  final double price;
  final int size;
  final String bedType;
  final int maxGuests;
  final List<String> amenities;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final List<String> images;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    required this.size,
    required this.bedType,
    required this.maxGuests,
    required this.amenities,
    required this.freeCancellation,
    required this.breakfastIncluded,
    required this.images,
  });
}