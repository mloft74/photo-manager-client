import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/home/pods/date_sorting_pod.dart';

class UpdateDateSortingDialog extends StatefulWidget {
  final DateSortingState currentSorting;

  const UpdateDateSortingDialog({
    required this.currentSorting,
    super.key,
  });

  @override
  State<UpdateDateSortingDialog> createState() =>
      _UpdateDateSortingDialogState();
}

class _UpdateDateSortingDialogState extends State<UpdateDateSortingDialog> {
  late DateSortingState _newSorting;

  @override
  void initState() {
    super.initState();
    _newSorting = widget.currentSorting;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sorting'),
      content: DropdownMenu<DateSortingState>(
        initialSelection: widget.currentSorting,
        onSelected: (value) {
          if (value != null) {
            setState(() {
              _newSorting = value;
            });
          }
        },
        dropdownMenuEntries:
            DateSortingState.values.map(_sortingEntry).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _newSorting),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

DropdownMenuEntry<DateSortingState> _sortingEntry(DateSortingState sorting) {
  return DropdownMenuEntry(
    value: sorting,
    label: switch (sorting) {
      DateSortingState.newToOld => 'New to old',
      DateSortingState.oldToNew => 'Old to new',
    },
  );
}
