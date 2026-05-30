enum OrderStatus {
  waitingRiderConfirmation(
    0,
    'Pending',
    'Searching For Rider',
  ),
  confirmed(
    1,
    'Confirmed',
    'Your order has been confirmed',
  ),
  preparing(
    2,
    'Preparing',
    'Your order is being prepared',
  ),
  outForDelivery(
    3,
    'Out for Delivery',
    'Your order is on the way!',
  ),
  delivered(
    4,
    'Delivered',
    'Order delivered successfully',
  ),
  cancelled(
    5,
    'Cancelled',
    'This order has been cancelled',
  );

  final int firestoreValue;
  final String label;
  final String description;

  const OrderStatus(this.firestoreValue, this.label, this.description);

  int toFirestore() => firestoreValue;

  String resolveDescription(Map<String, String>? overrides) {
    if (overrides != null && overrides.containsKey(name)) {
      return overrides[name]!;
    }
    return description;
  }

  static OrderStatus fromFirestore(Object? status) {
    if (status is int) {
      return OrderStatus.values.firstWhere(
        (e) => e.firestoreValue == status,
        orElse: () => OrderStatus.waitingRiderConfirmation,
      );
    }
    if (status is String) {
      return _fromLegacyString(status);
    }
    return OrderStatus.waitingRiderConfirmation;
  }

  static OrderStatus _fromLegacyString(String status) {
    switch (status) {
      case 'Waiting Rider Confirmation':
        return OrderStatus.waitingRiderConfirmation;
      case 'Confirmed':
        return OrderStatus.confirmed;
      case 'Preparing':
        return OrderStatus.preparing;
      case 'Out for Delivery':
        return OrderStatus.outForDelivery;
      case 'Delivered':
        return OrderStatus.delivered;
      case 'Cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.waitingRiderConfirmation;
    }
  }
}
