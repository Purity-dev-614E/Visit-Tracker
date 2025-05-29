import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_tracker/models/customer.dart';
import 'package:visit_tracker/screens/visit_detail_screen.dart';
import '../providers/customer_provider.dart';
import '../providers/visit_provider.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  @override
  void initState() {
    super.initState();
    final visitProvider = context.read<VisitProvider>();
    final customerProvider = context.read<CustomerProvider>();

    visitProvider.loadFromHive();
    visitProvider.loadFromApi();

    customerProvider.loadFromHive();
    customerProvider.loadFromApi();
  }

  Future<void> _refresh() async{
    await context.read<VisitProvider>().loadFromApi();
  }
  @override
  Widget build(BuildContext context) {
    final visits = context.watch<VisitProvider>().visits;
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Visits', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            tooltip: 'View Statistics',
            onPressed: () {
              Navigator.pushNamed(context, '/stats');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if(visits.any((v) => !v.isSynced))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange.shade50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await context.read<VisitProvider>().syncUnsyncVisits();
                },
                icon: Icon(Icons.sync),
                label: Text('Sync Pending Visits', style: TextStyle(fontSize: 16)),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: visits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No Visits Logged Yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh or tap + to add a visit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: visits.length,
                    itemBuilder: (_, index) {
                      final visit = visits[index];
                      final customer = customers.firstWhere(
                        (c) => c.id == visit.customerId,
                        orElse: () => Customer(
                          id: -1,
                          name: 'Unknown Customer',
                        ),
                      );

                      Color statusColor;
                      IconData statusIcon;
                      switch (visit.status.toLowerCase()) {
                        case 'completed':
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                          break;
                        case 'pending':
                          statusColor = Colors.orange;
                          statusIcon = Icons.pending;
                          break;
                        case 'cancelled':
                          statusColor = Colors.red;
                          statusIcon = Icons.cancel;
                          break;
                        default:
                          statusColor = Colors.grey;
                          statusIcon = Icons.help_outline;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisitDetailScreen(visit: visit)
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer?.name ?? 'Unknown Customer',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            visit.location,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!visit.isSynced)
                                      Tooltip(
                                        message: 'Not synced',
                                        child: Icon(
                                          Icons.cloud_off,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          statusIcon,
                                          color: statusColor,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          visit.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      visit.visitDate.toLocal().toString().split(' ')[0],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/add-visit');
        },
        icon: Icon(Icons.add),
        label: Text('Add Visit'),
        elevation: 2,
      ),
    );
  }
}
