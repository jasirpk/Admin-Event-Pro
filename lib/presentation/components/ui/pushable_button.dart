import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';
import 'package:pushable_button/pushable_button.dart';

class PushableButton_widget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onpressed;

  /// Swaps the label for a spinner and the [loadingText], and stops the button
  /// responding to taps.
  ///
  /// Optional and false by default, so the nine other screens using this
  /// button are unaffected.
  final bool isLoading;

  /// Shown beside the spinner while [isLoading].
  final String loadingText;

  const PushableButton_widget({
    super.key,
    required this.buttonText,
    required this.onpressed,
    this.isLoading = false,
    this.loadingText = 'Submitting...',
  });

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      elevation: 8,
      hslColor: HSLColor.fromColor(myColor),
      height: 50,
      shadow: BoxShadow(),
      // Null while loading. The package guards its callback with `?.call()`,
      // so this is what actually makes a second tap do nothing — the disabled
      // look alone would not.
      onPressed: isLoading ? null : onpressed,
      child: isLoading ? _loading() : _label(),
    );
  }

  Widget _label() => Text(
        buttonText,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
      );

  /// The spinner and its caption, both dark.
  ///
  /// The idle label inherits the theme's white `bodyMedium`, which on this
  /// button's `#0CFCDF` turquoise is already marginal; a white spinner on it
  /// would be close to invisible. These two are given an explicit dark colour
  /// so the feedback actually reads. The idle label is left exactly as it was.
  Widget _loading() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05322C)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            loadingText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Color(0xFF05322C),
            ),
          ),
        ],
      );
}
