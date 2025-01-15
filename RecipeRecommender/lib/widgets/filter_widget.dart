import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final Map<String, TextEditingController> filters;
  final VoidCallback onApplyFilters;

  const FilterWidget({
    required this.filters,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextField(
              controller: entry.value,
              decoration: InputDecoration(
                labelText: 'Filter by ${entry.key}',
                border: OutlineInputBorder(),
              ),
            ),
          );
        }).toList(),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: onApplyFilters,
          child: Text('Apply Filters'),
        ),
      ],
    );
  }
}
