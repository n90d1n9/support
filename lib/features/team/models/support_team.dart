enum SupportTeam {
  rideOperations,
  payments,
  finance,
  technicalSupport,
  fraud,
  safety,
  fleetOperations
}

extension SupportTeamX on SupportTeam {
  String get label {
    switch (this) {
      case SupportTeam.rideOperations:
        return 'Ride Operations';
      case SupportTeam.payments:
        return 'Payments';
      case SupportTeam.finance:
        return 'Finance';
      case SupportTeam.technicalSupport:
        return 'Technical Support';
      case SupportTeam.fraud:
        return 'Fraud';
      case SupportTeam.safety:
        return 'Safety';
      case SupportTeam.fleetOperations:
        return 'Fleet Operations';
    }
  }
}
