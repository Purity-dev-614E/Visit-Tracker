import 'package:visit_tracker/services/api_client.dart';

import '../models/customer.dart';

class CustomerService {
  final ApiClient _api = ApiClient();

  Future<List<Customer>> fetchCustomers() async {
    final data = await _api.get('customers');
    return data.map<Customer>((item) => Customer.fromJson(item)).toList();
  }
}
