import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../models/delivery_address_model.dart';

/// Interface for location-related data operations.
abstract class LocationDataSource {
  /// Requests location permission and gets the current device position.
  Future<Result<Position>> getCurrentPosition();

  /// Reverse-geocodes a position into a human-readable address string.
  Future<Result<String>> getAddressFromPosition(
    double latitude,
    double longitude,
  );

  /// Convenience method to get a full [DeliveryAddressModel] from the device.
  Future<Result<DeliveryAddressModel>> getCurrentAddress();
}

/// Implementation of [LocationDataSource] using geolocator + geocoding.
class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Result<Position>> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Result.failure(
          CheckoutFailure.locationFailed('Location services are disabled'),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Result.failure(
            CheckoutFailure.locationFailed('Location permission denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Result.failure(
          CheckoutFailure.locationFailed(
            'Location permission permanently denied. '
            'Please enable it in settings.',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      return Result.success(position);
    } catch (e) {
      return Result.failure(
        CheckoutFailure.locationFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> getAddressFromPosition(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return Result.success('$latitude, $longitude');
      }

      final placemark = placemarks.first;
      final parts = <String>[
        if (placemark.street != null && placemark.street!.isNotEmpty)
          placemark.street!,
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty)
          placemark.subLocality!,
        if (placemark.locality != null && placemark.locality!.isNotEmpty)
          placemark.locality!,
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty)
          placemark.administrativeArea!,
        if (placemark.country != null && placemark.country!.isNotEmpty)
          placemark.country!,
      ];

      return Result.success(parts.join(', '));
    } catch (e) {
      // Fallback to coordinates if geocoding fails
      return Result.success('$latitude, $longitude');
    }
  }

  @override
  Future<Result<DeliveryAddressModel>> getCurrentAddress() async {
    final positionResult = await getCurrentPosition();
    if (positionResult.isFailure) {
      return Result.failure(positionResult.failureOrNull!);
    }

    final position = positionResult.dataOrNull!;
    final addressResult = await getAddressFromPosition(
      position.latitude,
      position.longitude,
    );

    // getAddressFromPosition always returns success (catches exceptions and
    // falls back to coordinates), so addressResult.dataOrNull is safe.
    return Result.success(
      DeliveryAddressModel(
        latitude: position.latitude,
        longitude: position.longitude,
        addressLine: addressResult.dataOrNull!,
        label: 'Current Location',
      ),
    );
  }
}
