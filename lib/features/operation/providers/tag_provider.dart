import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagLibraryProvider = StateProvider<Set<String>>((_) => {
      'fare',
      'dispute',
      'refund',
      'safety',
      'urgent',
      'lost-item',
      'payment',
      'payout',
      'tech',
      'app',
      'promo',
      'voucher',
      'driver',
      'passenger',
      'fleet',
      'billing',
      'wallet',
      'fraud',
      'kyc'
    });
