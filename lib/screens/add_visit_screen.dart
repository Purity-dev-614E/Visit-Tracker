import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/providers/customer_provider.dart';
import 'package:visit_tracker/widgets/app_textfield.dart';
import 'package:visit_tracker/widgets/multi_select_chip.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../providers/visit_provider.dart';
import '../widgets/dropdown_selector.dart';

class AddVisitScreen extends StatefulWidget {
  final Visit? visit; // Optional visit for editing mode

  const AddVisitScreen({
    super.key,
    this.visit,
  });

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  @override
  void initState() {
    super.initState();
    // Load customers and activities from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      final activityProvider = context.read<ActivityProvider>();

      if (customerProvider.customers.isEmpty) {
        customerProvider.loadFromHive();
        customerProvider.loadFromApi();
      }

      if (activityProvider.activities.isEmpty) {
        activityProvider.loadFromHive();
        activityProvider.loadFromApi();
      }

      // If in edit mode, populate the form with existing visit data
      if (widget.visit != null) {
        _selectedCustomerId = widget.visit!.customerId;
        _selectedDate = widget.visit!.visitDate;
        _selectedStatus = widget.visit!.status;
        _locationController.text = widget.visit!.location;
        _noteController.text = widget.visit!.notes;
        _selectedActivities = List.from(widget.visit!.activityDone);
      }
    });
  }

  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedStatus;
  int? _selectedCustomerId;
  List<String> _selectedActivities = [];

  final List<String> _statusOptions = [
    'Pending',
    'Completed',
    'Cancelled',
  ];

  // Toggle an activity by ID
  void toggleActivity(String activityId) {
    setState(() {
      if (_selectedActivities.contains(activityId)) {
        _selectedActivities.remove(activityId);
        print('Removed activity ID: $activityId');
      } else {
        _selectedActivities.add(activityId);
        print('Added activity ID: $activityId');
      }
      print('Selected activities: $_selectedActivities');
    });
  }
  
  // Get the description for an activity ID
  String getActivityDescription(String activityId) {
    final activities = context.read<ActivityProvider>().activities;
    final activity = activities.firstWhere(
      (a) => a.id.toString() == activityId,
      orElse: () => Activity(id: 0, description: "Unknown")
    );
    return activity.description;
  }

  void submitForm() async {
    final logger = Logger();
    if (_selectedCustomerId == null ||
        _selectedDate == null ||
        _selectedActivities.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedStatus == null
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      logger.i('Please Fill All Fields');
      return;
    }
    try {
      // Create a visit object
      logger.i('Creating visit object');
      
      final visit = Visit(
          id: widget.visit?.id ?? 0,  // Use existing ID if editing, otherwise 0
          customerId: _selectedCustomerId!,
          visitDate: _selectedDate!,
          status: _selectedStatus!,
          location: _locationController.text,
          notes: _noteController.text,
          activityDone: _selectedActivities,
          isSynced: widget.visit?.isSynced ?? true
      );
      
      logger.i('Created visit object: ${visit.toJson()}');

      // Call the provider to add/update the visit
      logger.i('Calling VisitProvider.addVisit');
      await context.read<VisitProvider>().addVisit(visit);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.visit != null ? 'Visit updated successfully' : 'Visit added successfully')),
      );
      
      // Go back to previous screen
      Navigator.pop(context);
    } catch (e) {
      logger.e('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get data from providers
    final customers = context
        .watch<CustomerProvider>()
        .customers;
    final activities = context
        .watch<ActivityProvider>()
        .activities;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Visit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fill in the details of your customer visit',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Selection
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownSelector<int>(
                          label: '',
                          value: _selectedCustomerId,
                          items: customers.map((customer) {
                            return DropdownMenuItem(
                              value: customer.id,
                              child: Text(customer.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCustomerId = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Visit Date
                      Text(
                        'Visit Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey[800],
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _selectedDate = selectedDate;
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_today, size: 20),
                          label: Text(
                            _selectedDate != null
                                ? 'Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                                : 'Select Visit Date',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Status Selection
                      Text(
                        'Visit Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownSelector<String>(
                          label: '',
                          value: _selectedStatus,
                          items: _statusOptions.map((status) {
                            Color statusColor;
                            switch (status.toLowerCase()) {
                              case 'completed':
                                statusColor = Colors.green;
                                break;
                              case 'pending':
                                statusColor = Colors.orange;
                                break;
                              case 'cancelled':
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Colors.grey;
                            }
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    status == 'Completed' ? Icons.check_circle :
                                    status == 'Pending' ? Icons.pending :
                                    Icons.cancel,
                                    color: statusColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(status),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Location
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      AppTextfield(
                        label: '',
                        controller: _locationController,
                        prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                        hintText: 'Enter visit location',
                      ),
                      SizedBox(height: 24),

                      // Activities
                      Text(
                        'Activities Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          spacing: 8,
                          children: activities.map((activity) {
                            final isSelected = _selectedActivities.contains(activity.id.toString());
                            return FilterChip(
                              label: Text(activity.description),
                              selected: isSelected,
                              onSelected: (_) {
                                toggleActivity(activity.id.toString());
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Notes
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      AppTextfield(
                        label: '',
                        controller: _noteController,
                        maxLines: 3,
                        hintText: 'Add any additional notes about the visit',
                      ),
                      SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _selectedCustomerId != null &&
                                  _selectedDate != null &&
                                  _selectedStatus != null &&
                                  _locationController.text.isNotEmpty &&
                                  _selectedActivities.isNotEmpty
                              ? submitForm
                              : null,
                          child: Text(
                            'Submit Visit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
