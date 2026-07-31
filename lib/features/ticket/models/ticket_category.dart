enum TicketCategory {
  rideIssue,
  driverComplaint,
  passengerComplaint,
  paymentIssue,
  walletIssue,
  billingIssue,
  promotionIssue,
  lostAndFound,
  technicalProblem,
  accountVerification,
  fraudReport,
  safetyIncident
}

extension TicketCategoryX on TicketCategory {
  String get label {
    switch (this) {
      case TicketCategory.rideIssue:
        return 'Ride Issue';
      case TicketCategory.driverComplaint:
        return 'Driver Complaint';
      case TicketCategory.passengerComplaint:
        return 'Passenger Complaint';
      case TicketCategory.paymentIssue:
        return 'Payment Issue';
      case TicketCategory.walletIssue:
        return 'Wallet Issue';
      case TicketCategory.billingIssue:
        return 'Billing Issue';
      case TicketCategory.promotionIssue:
        return 'Promotion Issue';
      case TicketCategory.lostAndFound:
        return 'Lost & Found';
      case TicketCategory.technicalProblem:
        return 'Technical Problem';
      case TicketCategory.accountVerification:
        return 'Account Verification';
      case TicketCategory.fraudReport:
        return 'Fraud Report';
      case TicketCategory.safetyIncident:
        return 'Safety Incident';
    }
  }

  bool get isSafetyCritical =>
      this == TicketCategory.safetyIncident ||
      this == TicketCategory.fraudReport;
}
