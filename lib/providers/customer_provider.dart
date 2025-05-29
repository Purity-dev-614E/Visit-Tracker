import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:visit_tracker/services/customer_service.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _service = CustomerService();
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  Future<void> loadFromApi()  async {
    _customers = await _service.fetchCustomers();
    final box = Hive.box<Customer>('customers');
    await box.clear();
    for(final customer in _customers) {
      box.put(customer.id, customer);
    }
    notifyListeners();
  }

  void loadFromHive(){
    final box = Hive.box<Customer>('customers');
    _customers = box.values.toList();
    notifyListeners();
  }

  Customer? getCustomerById(int id) {
    return _customers.firstWhere((customer) => customer.id == id, orElse: () =>
    Customer(id: id, name: "Unknown"));
  }
}