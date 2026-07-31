enum CustomerType { passenger, driver, fleetOperator, merchant, admin }

extension CustomerTypeX on CustomerType {
  String get label {
    switch (this) {
      case CustomerType.passenger:
        return 'Passenger';
      case CustomerType.driver:
        return 'Driver';
      case CustomerType.fleetOperator:
        return 'Fleet Operator';
      case CustomerType.merchant:
        return 'Merchant';
      case CustomerType.admin:
        return 'Admin';
    }
  }
}
