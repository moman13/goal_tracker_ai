import 'package:flutter/foundation.dart';

class Goal {
  final String title;
  final String description;
  final DateTime deadline;

  Goal({
    required this.title,
    required this.description,
    required this.deadline,
  });
}
