import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';

class ArchiveScreen extends StatefulWidget {
  final GoalService goalService;

  const ArchiveScreen({
    super.key,
    required this.goalService,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Goal> _archivedGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedGoals();
  }

  @override
  void didUpdateWidget(ArchiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh goals when the widget is updated (e.g., when tab is selected)
    _loadArchivedGoals();
  }

  Future<void> _loadArchivedGoals() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final goals = await widget.goalService.getAllGoals();
      if (!mounted) return;
      setState(() {
        _archivedGoals = goals
            .where((goal) =>
                goal.status == GoalStatus.completed ||
                goal.status == GoalStatus.failed)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load archived goals')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Archive'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadArchivedGoals,
              child: _archivedGoals.isEmpty
                  ? Center(
                      child: Text(
                        'No archived goals yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _archivedGoals.length,
                      itemBuilder: (context, index) {
                        final goal = _archivedGoals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              goal.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                decoration: goal.status == GoalStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goal.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${DateFormat('MMM dd, yyyy').format(goal.date)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Deadline: ${DateFormat('MMM dd, yyyy').format(goal.deadline)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: goal.status == GoalStatus.completed
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: goal.status == GoalStatus.completed
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    goal.status == GoalStatus.completed
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 16,
                                    color: goal.status == GoalStatus.completed
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    goal.status == GoalStatus.completed
                                        ? 'Completed'
                                        : 'Failed',
                                    style: TextStyle(
                                      color: goal.status == GoalStatus.completed
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
