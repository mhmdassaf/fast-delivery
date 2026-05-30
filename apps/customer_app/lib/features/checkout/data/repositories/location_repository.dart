import 'package:fast_delivery_core/errors/result.dart';

import '../datasources/location_datasource.dart';
import '../models/delivery_address_model.dart';

/// Repository for location-related operations.
///
/// Wraps [LocationDataSource] and can add caching or business logic later.
abstract class LocationRepository {
  /// Gets the current device address with location permission handling.
  Future<Result<DeliveryAddressModel>> getCurrentAddress();
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _dataSource;

  LocationRepositoryImpl({required LocationDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<DeliveryAddressModel>> getCurrentAddress() {
    return _dataSource.getCurrentAddress();
  }
}
