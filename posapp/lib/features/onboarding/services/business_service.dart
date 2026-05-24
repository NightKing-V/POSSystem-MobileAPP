import 'dart:async';

class BusinessProfileDetails {
  final String id;
  final String name;
  final String category;
  final String currency;
  final String location;
  final String planTier;

  const BusinessProfileDetails({
    required this.id,
    required this.name,
    required this.category,
    required this.currency,
    required this.location,
    required this.planTier,
  });
}

abstract class BusinessService {
  Future<BusinessProfileDetails> registerBusiness({
    required String name,
    required String category,
    required String currency,
    required String location,
    required String planTier,
  });
}

class MockBusinessService implements BusinessService {
  @override
  Future<BusinessProfileDetails> registerBusiness({
    required String name,
    required String category,
    required String currency,
    required String location,
    required String planTier,
  }) async {
    // Simulate brief network latency for database creation
    await Future.delayed(const Duration(milliseconds: 1200));

    return BusinessProfileDetails(
      id: 'b-dyn-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      currency: currency,
      location: location,
      planTier: planTier,
    );
  }
}
