import 'dart:io';

import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';

/// The visual language of the vendor form.
///
/// One place for the surfaces, borders, radii and type scale the Vendor
/// Preview screen is built from, so the page reads as a single system instead
/// of a pile of individually styled widgets. The palette is the app's own: the
/// black scaffold from [ThemeData.scaffoldBackgroundColor] and the turquoise
/// [myColor] accent from `common/style.dart`.
///
/// These pieces are deliberately free of business logic — every one takes its
/// controllers and callbacks from the caller — so the Edit Vendor form can
/// adopt them later without a behavioural change.
class VendorForm {
  const VendorForm._();

  /// Radius for cards, image tiles and anything that reads as a surface.
  static const double cardRadius = 16;

  /// Radius for text inputs. Slightly tighter than [cardRadius] so a field
  /// sitting inside a card does not look like a second card.
  static const double fieldRadius = 12;

  /// A panel one step above the page background.
  static Color get surface => const Color(0xFF14181B);

  /// A panel one step above [surface], for chips and controls that sit on it.
  static Color get surfaceRaised => Colors.white.withValues(alpha: 0.05);

  /// The hairline that separates a surface from the background.
  static Color get border => Colors.white.withValues(alpha: 0.09);

  /// Body copy. Full white is reserved for values the user typed.
  static Color get bodyColor => Colors.white.withValues(alpha: 0.78);

  /// Labels, hints and other secondary text.
  static Color get labelColor => Colors.white.withValues(alpha: 0.52);

  /// The accent at a tint that works as a fill behind an accent icon.
  static Color get accentSoft => myColor.withValues(alpha: 0.14);

  /// Section titles, in the display face the rest of the app already uses.
  static TextStyle get sectionTitle => TextStyle(
        color: myColor,
        fontFamily: 'JacquesFracois',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
      );

  /// The one-line explanation under a section title.
  static TextStyle get caption => TextStyle(
        color: labelColor,
        fontSize: 11.5,
        height: 1.3,
        fontWeight: FontWeight.w400,
      );

  /// What the user types, everywhere on the form.
  static const TextStyle inputText = TextStyle(
    color: Colors.white,
    fontSize: 14.5,
    fontWeight: FontWeight.w500,
  );

  /// The shared decoration for every input on the page.
  ///
  /// Filled rather than outlined-on-black, so a field is legible as a target
  /// before it is focused, and the accent is spent only on the focused border
  /// and the floating label — the two places it carries information.
  static InputDecoration input({
    required String labelText,
    String? hintText,
    IconData? icon,
    Widget? suffixIcon,
    String? errorText,
    bool alignLabelWithHint = false,
    bool dense = false,
  }) {
    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      alignLabelWithHint: alignLabelWithHint,
      isDense: dense,
      filled: true,
      fillColor: surface,
      prefixIcon: icon == null ? null : Icon(icon, size: 19, color: labelColor),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: labelColor, fontSize: 13.5),
      floatingLabelStyle: TextStyle(
        color: myColor,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.30),
        fontSize: 13.5,
      ),
      errorStyle: const TextStyle(fontSize: 11.5),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: dense ? 12 : 16,
      ),
      border: outline(border),
      enabledBorder: outline(border),
      focusedBorder: outline(myColor, 1.4),
      errorBorder: outline(Colors.redAccent.withValues(alpha: 0.7)),
      focusedErrorBorder: outline(Colors.redAccent, 1.4),
    );
  }
}

/// A rounded dark panel: the page's one container shape.
class VendorFormCard extends StatelessWidget {
  const VendorFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: VendorForm.surfaceRaised,
        borderRadius: BorderRadius.circular(VendorForm.cardRadius),
        border: Border.all(color: VendorForm.border),
      ),
      child: child,
    );
  }
}

/// Title, optional icon, optional one-line explanation, optional control.
///
/// Every section on the page opens with one of these, which is what gives the
/// form a readable hierarchy instead of a run of same-sized headings.
class VendorSectionHeader extends StatelessWidget {
  const VendorSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: myColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: VendorForm.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: VendorForm.caption),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

/// The page's introductory paragraph, collapsed to [collapsedLines].
///
/// The copy is unchanged and still reachable in full — it is folded rather
/// than cut, which is what takes roughly five lines of dead height off the
/// top of the screen without losing anything.
class VendorFormIntro extends StatefulWidget {
  const VendorFormIntro({
    super.key,
    required this.text,
    this.collapsedLines = 2,
  });

  final String text;
  final int collapsedLines;

  @override
  State<VendorFormIntro> createState() => _VendorFormIntroState();
}

class _VendorFormIntroState extends State<VendorFormIntro> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: VendorForm.surfaceRaised,
        borderRadius: BorderRadius.circular(VendorForm.cardRadius),
        border: Border.all(color: VendorForm.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: VendorForm.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 16, color: myColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    maxLines: _expanded ? null : widget.collapsedLines,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: VendorForm.bodyColor,
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? 'Show less' : 'Read more',
                          style: TextStyle(
                            color: myColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: myColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The category picker, as selectable chips.
///
/// Tapping one writes the category into [nameEditingController], exactly as
/// the previous grid of grey boxes did. The difference is that the selection
/// is now visible: the field is the single source of truth, so the chip is
/// driven from the controller rather than from a second copy of the state,
/// and a name the user types by hand correctly deselects every chip.
class VendorCategoryChips extends StatelessWidget {
  const VendorCategoryChips({
    super.key,
    required this.names,
    required this.nameEditingController,
  });

  final List<Map<String, String>> names;
  final TextEditingController nameEditingController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: nameEditingController,
      builder: (context, value, _) {
        final current = value.text.trim().toLowerCase();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in names)
              _VendorCategoryChip(
                label: entry['name'] ?? 'NO name',
                selected:
                    (entry['name'] ?? '').trim().toLowerCase() == current &&
                        current.isNotEmpty,
                onTap: () =>
                    nameEditingController.text = entry['name'] ?? 'NO name',
              ),
          ],
        );
      },
    );
  }
}

class _VendorCategoryChip extends StatelessWidget {
  const _VendorCategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(selected ? 11 : 14, 9, 14, 9),
          decoration: BoxDecoration(
            color: selected ? myColor : VendorForm.surfaceRaised,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: selected ? myColor : VendorForm.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 15, color: Colors.black),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.black : VendorForm.bodyColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A `−  n  +` pill.
///
/// Replaces two bare icon buttons with a single control that also states how
/// many rows there are, so the user is not left counting cards.
class VendorStepper extends StatelessWidget {
  const VendorStepper({
    super.key,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VendorForm.surfaceRaised,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: VendorForm.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: onRemove,
            tooltip: 'Remove the last component',
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 22),
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            tooltip: 'Add a component',
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 19, color: myColor),
          ),
        ),
      ),
    );
  }
}

/// What an image tile shows before anything has been chosen.
///
/// An invitation rather than a grey rectangle: a tinted accent badge, a verb
/// and, where there is room for it, a line saying where the picture comes
/// from.
class VendorImageEmptyState extends StatelessWidget {
  const VendorImageEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.add_photo_alternate_outlined,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double badge = compact ? 36 : 46;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: badge,
            height: badge,
            decoration: BoxDecoration(
              color: VendorForm.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: compact ? 18 : 23, color: myColor),
          ),
          SizedBox(height: compact ? 8 : 11),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null && !compact) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: VendorForm.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// The dark-to-transparent wash that keeps a label legible over a photograph.
class VendorImageScrim extends StatelessWidget {
  const VendorImageScrim({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.72),
              Colors.black.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small translucent pill, for "Change photo" and the like.
class VendorImageBadge extends StatelessWidget {
  const VendorImageBadge({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A round translucent button, sized for an image corner.
///
/// [IconButton] cannot be used here: its 48dp minimum tap target swamps a
/// 150dp-wide thumbnail.
class VendorImageActionButton extends StatelessWidget {
  const VendorImageActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 30,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.62),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.52, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// The listing's main picture: a 16:9 upload surface.
///
/// Shows, in this order of precedence, the file the user just picked, then the
/// template's stored picture, then an empty state. That order matches the save
/// path, which uploads the local file whenever there is one — showing the
/// template picture while storing a different image would be a quiet lie.
///
/// An R2 object key is not a URL, so the template branch goes through
/// [MediaImage], which signs it and falls back to the shared placeholder while
/// it resolves or if it fails. A file the user picks in this form is a [File]
/// on disk and never goes near the Media API.
class VendorMainImagePicker extends StatelessWidget {
  const VendorMainImagePicker({
    super.key,
    required this.imagePath,
    required this.image,
    required this.onTap,
  });

  /// The template's R2 object key, when this form was opened from one.
  final String? imagePath;

  /// The picture the user picked in this form, if any.
  final File? image;

  final VoidCallback onTap;

  bool get _hasTemplateImage => (imagePath ?? '').isNotEmpty;

  bool get _hasAnyImage => image != null || _hasTemplateImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: VendorForm.surface,
            borderRadius: BorderRadius.circular(VendorForm.cardRadius),
            border: Border.all(
              color: _hasAnyImage ? Colors.transparent : VendorForm.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _hasAnyImage ? _preview(context) : _empty(),
        ),
      ),
    );
  }

  Widget _empty() => const VendorImageEmptyState(
        title: 'Upload main image',
        subtitle: 'Tap to choose a photo from your gallery',
      );

  Widget _preview(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (image != null)
          Image.file(image!, fit: BoxFit.cover)
        else
          MediaImage(
            imagePath: imagePath,
            placeholder: kMediaPlaceholderImage,
            builder: (context, resolved) => Image(
              image: resolved ?? kMediaPlaceholderImage,
              fit: BoxFit.cover,
            ),
          ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: VendorImageScrim(),
        ),
        const Positioned(
          left: 12,
          bottom: 12,
          child: VendorImageBadge(
            label: 'Change photo',
            icon: Icons.edit_rounded,
          ),
        ),
      ],
    );
  }
}

/// The budget range, as two fields that read as one control.
class VendorBudgetRange extends StatelessWidget {
  const VendorBudgetRange({
    super.key,
    required this.fromController,
    required this.toController,
  });

  final TextEditingController fromController;
  final TextEditingController toController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _field('Minimum', fromController)),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          child: Text(
            '—',
            style: TextStyle(color: VendorForm.labelColor, fontSize: 14),
          ),
        ),
        Expanded(child: _field('Maximum', toController)),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextFormField(
        controller: controller,
        // Unchanged from the previous implementation: the parser on submit is
        // double.parse, and this keyboard is what it has always been fed.
        keyboardType: TextInputType.datetime,
        cursorColor: myColor,
        style: VendorForm.inputText,
        decoration: VendorForm.input(
          labelText: label,
          hintText: '0',
          icon: Icons.currency_rupee_rounded,
        ),
      ),
    );
  }
}
