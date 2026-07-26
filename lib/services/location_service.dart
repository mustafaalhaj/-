import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && !kIsWeb) {
        debugPrint('Location service disabled.');
        return null;
      }
    } catch (e) {
      debugPrint('Error checking location service: $e');
    }

    // 2. Check and request location permissions (On Web: triggers browser location prompt)
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever.');
        return null;
      }
    } catch (e) {
      debugPrint('Error checking/requesting location permission: $e');
    }

    // 3. Get Current Position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  Future<Placemark?> getPlacemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Web and Windows Desktop Reverse Geocoding via Nominatim OpenStreetMap API
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&accept-language=ar',
        );
        final response = await http.get(url, headers: {
          'User-Agent': 'AnaMuslimApp/1.0',
        }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] ?? {};
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state'] ??
              address['county'] ??
              '';
          final country = address['country'] ?? '';

          return Placemark(locality: city, country: country);
        }
      } catch (e) {
        debugPrint('Web/Desktop reverse geocoding fallback error: $e');
      }
      return null;
    }

    // Mobile (Android / iOS) native reverse geocoding
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final place = await getPlacemarkFromCoordinates(latitude, longitude);
    if (place != null) {
      final locality = place.locality ?? '';
      final country = place.country ?? '';
      if (locality.isNotEmpty && country.isNotEmpty) {
        return '$locality, $country';
      } else if (locality.isNotEmpty) {
        return locality;
      } else if (country.isNotEmpty) {
        return country;
      }
    }
    return null;
  }
}
