import 'package:flutter/material.dart';

class PopubMenuButton extends StatelessWidget {
  const PopubMenuButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text('Edit'),
            value: 'edit',
          ),
          PopupMenuItem(
            child: Text('Delete'),
            value: 'delete',
          ),
          PopupMenuItem(
            child: Text('Details'),
            value: 'details',
          ),
          PopupMenuItem(
            child: Text('Submit'),
            value: 'submit',
          ),
        ];
      },
      onSelected: (value) async {
        if (value == 'edit') {
        } else if (value == 'delete') {
        } else if (value == 'details') {
        } else if (value == 'submit') {}
      },
    );
  }
}
