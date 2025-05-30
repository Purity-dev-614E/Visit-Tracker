import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_tracker/models/visit.dart';
import '../providers/activity_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/visit_provider.dart';
import 'add_visit_screen.dart';

class VisitDetailScreen extends StatelessWidget {
  final Visit visit;

  const VisitDetailScreen({
    super.key,
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final visitProvider = context.watch<VisitProvider>();

    final customerName = customerProvider.getCustomerById(visit.customerId)?.name ?? 'Unknown Customer';

    // Get activity descriptions from IDs
    final activityDescriptions = visit.activityDone.map((activityId) {
      final description = activityProvider.getDescription(activityId);
      print('Activity ID: $activityId, Description: $description');
      return description;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVisitScreen(visit: visit),
                ),
              );
            },
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Visit'),
                  content: Text('Are you sure you want to delete this visit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await visitProvider.deleteVisit(visit.id);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to list
                      },
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(visit.status).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(visit.status),
                        color: _getStatusColor(visit.status),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        visit.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(visit.status),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!visit.isSynced) ...[
                        SizedBox(width: 8),
                        Icon(
                          Icons.cloud_off,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Not Synced',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    visit.visitDate.toLocal().toString().split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Card
                  _buildDetailCard(
                    context,
                    title: 'Location',
                    icon: Icons.location_on,
                    content: visit.location,
                  ),
                  SizedBox(height: 16),

                  // Activities Card
                  _buildDetailCard(
                    context,
                    title: 'Activities Done',
                    icon: Icons.checklist,
                    content: '',
                    customContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: activityDescriptions.map((activity) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activity,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Notes Card
                  if (visit.notes.isNotEmpty)
                    _buildDetailCard(
                      context,
                      title: 'Notes',
                      icon: Icons.note,
                      content: visit.notes,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    Widget? customContent,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (customContent != null)
              customContent
            else
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value))
        ],
      ),
    );
  }
}

