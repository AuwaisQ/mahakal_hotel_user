
import 'package:flutter/material.dart';

import '../widgets/hotel_uihelper.dart';
import 'hotel_model.dart';

class DummyData {
  static List<Hotel> hotels = [
    Hotel(
      id: '1',
      name: 'Taj Mahal Palace',
      location: 'Mumbai, India',
      rating: 4.8,
      reviews: 2453,
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      amenities: ['Pool', 'Spa', 'Gym', 'WiFi', 'Restaurant', 'Bar'],
      distance: 2.5,
      stars: 5,
      isFeatured: true,
      discount: 20,
      description: 'Luxury 5-star hotel with sea view and world-class amenities.',
    ),
    Hotel(
      id: '2',
      name: 'The Leela Palace',
      location: 'New Delhi, India',
      rating: 4.7,
      reviews: 1892,
      price: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      amenities: ['Pool', 'Spa', 'Gym', 'WiFi', 'Parking', 'Restaurant'],
      distance: 3.2,
      stars: 5,
      isFeatured: true,
      discount: 15,
      description: 'Royal palace-style hotel with luxurious rooms and excellent service.',
    ),
    Hotel(
      id: '3',
      name: 'ITC Grand Chola',
      location: 'Chennai, India',
      rating: 4.6,
      reviews: 1678,
      price: 9000,
      imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      amenities: ['Pool', 'Spa', 'Gym', 'WiFi', 'Business Center', 'Restaurant'],
      distance: 1.8,
      stars: 5,
      isFeatured: false,
      description: 'Grand luxury hotel with traditional South Indian architecture.',
    ),
    Hotel(
      id: '4',
      name: 'Oberoi Udaivilas',
      location: 'Udaipur, India',
      rating: 4.9,
      reviews: 3124,
      price: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      amenities: ['Pool', 'Spa', 'Gym', 'WiFi', 'Lake View', 'Restaurant'],
      distance: 4.5,
      stars: 5,
      isFeatured: true,
      discount: 10,
      description: 'Palace hotel on the banks of Lake Pichola with breathtaking views.',
    ),
  ];

  static List<Room> rooms = [
    Room(
      id: '1',
      hotelId: '1',
      type: 'Deluxe Room',
      price: 15000,
      size: 45,
      bedType: 'King Bed',
      maxGuests: 3,
      amenities: ['AC', 'TV', 'Mini Bar', 'WiFi', 'Bathtub'],
      freeCancellation: true,
      breakfastIncluded: true,
      images: [
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
      ],
    ),
    Room(
      id: '2',
      hotelId: '1',
      type: 'Premium Suite',
      price: 25000,
      size: 85,
      bedType: 'King Bed + Sofa Bed',
      maxGuests: 4,
      amenities: ['AC', 'TV', 'Mini Bar', 'WiFi', 'Bathtub', 'Living Room'],
      freeCancellation: true,
      breakfastIncluded: true,
      images: [
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
      ],
    ),
  ];

  static List<String> destinations = [
    'Goa', 'Kerala', 'Rajasthan', 'Himachal', 'Kashmir', 'Andaman'
  ];

  static List<Map<String, dynamic>> categories = [
    {'icon': Icons.business_center, 'title': 'Business', 'color': AppColors.blue},
    {'icon': Icons.favorite, 'title': 'Romantic', 'color': AppColors.red},
    {'icon': Icons.family_restroom, 'title': 'Family', 'color': AppColors.green},
    {'icon': Icons.beach_access, 'title': 'Beach', 'color': AppColors.yellow},
    {'icon': Icons.landscape, 'title': 'Mountain', 'color': AppColors.black},
  ];
}