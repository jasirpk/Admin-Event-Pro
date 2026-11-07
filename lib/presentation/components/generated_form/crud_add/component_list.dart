import 'dart:io';

import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/generated_form/vendor_form_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The horizontal strip of "essential component" cards.
///
/// One card per slot the stepper has opened: a picture and the caption that
/// goes with it. The slots themselves, and the pictures in them, belong to
/// [GeneratedBloc]; the captions are the controllers the parent owns.
class ComponentsWidget extends StatelessWidget {
  const ComponentsWidget({
    super.key,
    required this.screenHeight,
    required this.itemCount,
    required this.imageNameControllers,
    required this.screenWidth,
    required this.images,
  });

  final double screenHeight;
  final int? itemCount;
  final List<TextEditingController> imageNameControllers;
  final double screenWidth;
  final List<File?>? images;

  @override
  Widget build(BuildContext context) {
    final count = itemCount ?? 0;
    if (count == 0) return const SizedBox.shrink();

    // Clamped rather than a bare fraction of the screen: the old tiles were a
    // third of the viewport tall on a big phone and cramped on a small one.
    final double cardWidth = (screenWidth * 0.42).clamp(148.0, 190.0);
    final double stripHeight = (screenHeight * 0.24).clamp(188.0, 212.0);

    return SizedBox(
      height: stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // Unchanged: captions are created lazily as a card scrolls into
          // view, and Fields._prepareImagesData tolerates a short list.
          if (imageNameControllers.length <= index) {
            imageNameControllers.add(TextEditingController());
          }

          final file = (images != null && index < images!.length)
              ? images![index]
              : null;

          return SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ComponentImageTile(
                    index: index,
                    file: file,
                    onPick: () => context
                        .read<GeneratedBloc>()
                        .add(PickImageEvent(index)),
                    onRemove: () => context
                        .read<GeneratedBloc>()
                        .add(RemoveImageEvent(index)),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: imageNameControllers[index],
                  cursorColor: myColor,
                  textCapitalization: TextCapitalization.words,
                  style: VendorForm.inputText.copyWith(fontSize: 13.5),
                  decoration: VendorForm.input(
                    labelText: 'Image Name',
                    dense: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ComponentImageTile extends StatelessWidget {
  const _ComponentImageTile({
    required this.index,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  final int index;
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        decoration: BoxDecoration(
          color: VendorForm.surface,
          borderRadius: BorderRadius.circular(VendorForm.cardRadius),
          border: Border.all(
            color: hasImage ? Colors.transparent : VendorForm.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.file(file!, fit: BoxFit.cover)
            else
              const VendorImageEmptyState(
                title: 'Add photo',
                compact: true,
              ),
            if (hasImage) ...[
              const Align(
                alignment: Alignment.bottomCenter,
                child: VendorImageScrim(height: 48),
              ),
              const Positioned(
                left: 8,
                bottom: 8,
                child: VendorImageBadge(
                  label: 'Change',
                  icon: Icons.edit_rounded,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: VendorImageActionButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Remove this photo',
                  onTap: onRemove,
                ),
              ),
            ],
            // The slot number, so a caption typed into the wrong card is
            // obvious before the listing is submitted.
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
