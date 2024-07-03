import 'package:flutter/material.dart';

class FullscreenSnackbar {
  void showFullScreenSnackbar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            backgroundBlendMode: BlendMode.darken,
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
