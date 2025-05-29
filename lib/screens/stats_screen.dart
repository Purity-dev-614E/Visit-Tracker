import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../providers/customer_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedStatus;
  int? _selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final visitProvider = context.watch<VisitProvider>();
    final customerProvider = context.watch<CustomerProvider>();

    final visits = visitProvider.visits;
    final customers = customerProvider.customers;

    // Filter logic
    final filtered = visits.where((visit) {
      final statusMatch = _selectedStatus == null || visit.status == _selectedStatus;
      final customerMatch = _selectedCustomerId == null || visit.customerId == _selectedCustomerId;
      return statusMatch && customerMatch;
    }).toList();

    final statusCounts = {
      for (var status in ['Completed', 'Pending', 'Cancelled'])
        status: visits.where((v) => v.status == status).length
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Visit Statistics", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats Overview Cards
          Container(
            padding: EdgeInsets.all(16),
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
                  'Visit Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Completed',
                        count: statusCounts['Completed'] ?? 0,
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Pending',
                        count: statusCounts['Pending'] ?? 0,
                        color: Colors.orange,
                        icon: Icons.pending,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Cancelled',
                        count: statusCounts['Cancelled'] ?? 0,
                        color: Colors.red,
                        icon: Icons.cancel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Status Filter
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: ['Completed', 'Pending', 'Cancelled']
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(
                                        children: [
                                          Icon(
                                            s == 'Completed' ? Icons.check_circle :
                                            s == 'Pending' ? Icons.pending :
                                            Icons.cancel,
                                            color: s == 'Completed' ? Colors.green :
                                                   s == 'Pending' ? Colors.orange :
                                                   Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(s),
                                        ],
                                      ),
                                    ))
                                .toList()
                              ..insert(0, DropdownMenuItem(
                                value: null,
                                child: Text('All Statuses'),
                              )),
                            onChanged: (val) => setState(() => _selectedStatus = val),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Customer Filter
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCustomerId,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: customers
                                .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ))
                                .toList()
                              ..insert(0, DropdownMenuItem(
                                value: null,
                                child: Text('All Customers'),
                              )),
                            onChanged: (val) => setState(() => _selectedCustomerId = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtered Visits List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No visits match the filters',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final visit = filtered[index];
                      final customerName = customerProvider.getCustomerById(visit.customerId)?.name ?? "Unknown";
                      final statusColor = visit.status == 'Completed' ? Colors.green :
                                       visit.status == 'Pending' ? Colors.orange :
                                       Colors.red;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Icon(
                              visit.status == 'Completed' ? Icons.check_circle :
                              visit.status == 'Pending' ? Icons.pending :
                              Icons.cancel,
                              color: statusColor,
                            ),
                          ),
                          title: Text(
                            customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                visit.location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    visit.visitDate.toLocal().toString().split(" ")[0],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              visit.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
