import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:flutter/material.dart';

class LinkFieldsWidget extends StatelessWidget {
  const LinkFieldsWidget({
    super.key,
    required this.fieldCount,
    required this.fields,
  });

  final int? fieldCount;
  final List<TextEditingController> fields;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: fieldCount,
      itemBuilder: (context, index) {
        if (fields.length <= index) {
          fields.add(TextEditingController());
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomTextFieldWidget(
            readOnly: false,
            keyboardtype: TextInputType.emailAddress,
            controller: fields[index],
            labelText: 'link',
          ),
        );
      },
    );
  }
}
