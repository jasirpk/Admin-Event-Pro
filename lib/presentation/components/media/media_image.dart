import 'package:flutter/material.dart';

import 'package:admineventpro/data_layer/services/media_image_resolver.dart';

/// The image shown wherever a template picture is missing, still resolving, or
/// failed to resolve. One constant so every list, grid and detail header falls
/// back to the same thing.
const String kMediaPlaceholderAsset = 'assets/images/place holder.jpg';

/// [kMediaPlaceholderAsset] as a provider, for [MediaImage.placeholder].
const AssetImage kMediaPlaceholderImage = AssetImage(kMediaPlaceholderAsset);

/// Renders whatever a Firestore `imagePath` points at — a legacy Firebase
/// Storage URL, a bundled asset, or an R2 objectKey that needs signing.
///
/// [builder] receives the resolved [ImageProvider], or [placeholder] while an
/// objectKey is being signed and if signing fails. The surrounding layout is
/// therefore built exactly once and never swaps in a spinner. Paths that need
/// no network round-trip are resolved before the first frame, so the common
/// case doesn't flash the placeholder at all.
class MediaImage extends StatefulWidget {
  const MediaImage({
    super.key,
    required this.imagePath,
    required this.builder,
    this.placeholder,
  });

  /// The raw Firestore value. Null, empty and unresolvable values fall back to
  /// [placeholder].
  final String? imagePath;

  /// Stands in until the real image is available, and instead of it on
  /// failure. Null means the caller renders its own empty state.
  final ImageProvider? placeholder;

  final Widget Function(BuildContext context, ImageProvider? image) builder;

  @override
  State<MediaImage> createState() => _MediaImageState();
}

class _MediaImageState extends State<MediaImage> {
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only a different path is worth re-resolving; a plain rebuild (a parent
    // stream tick, a scroll) must not hit the Media API again.
    if (oldWidget.imagePath != widget.imagePath) _load();
  }

  void _load() {
    // Resolving synchronously first is what avoids a placeholder frame for
    // legacy URLs, assets and already-signed objectKeys.
    final immediate = MediaImageResolver.instance.resolveSync(widget.imagePath);
    if (immediate != null) {
      _image = immediate;
      return;
    }

    _image = null;

    final requested = widget.imagePath;
    MediaImageResolver.instance.resolve(requested).then((resolved) {
      // This tile may have been disposed, or recycled onto another document,
      // while the Media API call was in flight.
      if (!mounted || requested != widget.imagePath || resolved == null) return;
      setState(() => _image = resolved);
    });
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _image ?? widget.placeholder);
}

/// Where a [MediaUrl] has got to.
enum MediaUrlStatus {
  /// An objectKey is being signed. Nothing displayable yet.
  resolving,

  /// A URL is available and is passed to the builder.
  resolved,

  /// No URL will arrive: signing failed, or the path is one that has no URL at
  /// all (empty, or a bundled asset).
  failed,
}

/// The URL counterpart of [MediaImage], for widgets that take a URL string
/// rather than an [ImageProvider] — `CachedNetworkImage`, chiefly.
///
/// [builder] receives the resolved URL. Supply [loadingBuilder] and
/// [errorBuilder] to tell "still signing" apart from "cannot be shown"; a
/// caller that supplies neither keeps the original contract, where [builder]
/// is called with null in both of those states.
///
/// Prefer supplying them. Handing a null URL on to `CachedNetworkImage` means
/// passing it the empty string, which fails immediately and renders the error
/// widget, so a tile that is merely still loading is indistinguishable from
/// one that genuinely failed.
class MediaUrl extends StatefulWidget {
  const MediaUrl({
    super.key,
    required this.imagePath,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String? imagePath;
  final Widget Function(BuildContext context, String? url) builder;

  /// Shown while an objectKey is being signed.
  final WidgetBuilder? loadingBuilder;

  /// Shown when no URL can be produced.
  final WidgetBuilder? errorBuilder;

  @override
  State<MediaUrl> createState() => _MediaUrlState();
}

class _MediaUrlState extends State<MediaUrl> {
  String? _url;
  MediaUrlStatus _status = MediaUrlStatus.resolving;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MediaUrl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) _load();
  }

  void _load() {
    final immediate =
        MediaImageResolver.instance.resolveUrlSync(widget.imagePath);
    if (immediate != null) {
      _url = immediate;
      _status = MediaUrlStatus.resolved;
      return;
    }

    // An empty path or a bundled asset has no URL to wait for, so settle now
    // rather than showing a spinner for a round-trip that will never happen.
    if (MediaImageResolver.instance.hasNoResolvableUrl(widget.imagePath)) {
      _url = null;
      _status = MediaUrlStatus.failed;
      return;
    }

    _url = null;
    _status = MediaUrlStatus.resolving;

    final requested = widget.imagePath;
    MediaImageResolver.instance.resolveUrl(requested).then((url) {
      if (!mounted || requested != widget.imagePath) return;
      setState(() {
        _url = url;
        _status = url == null ? MediaUrlStatus.failed : MediaUrlStatus.resolved;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case MediaUrlStatus.resolved:
        return widget.builder(context, _url);
      case MediaUrlStatus.resolving:
        final loading = widget.loadingBuilder;
        return loading != null ? loading(context) : widget.builder(context, null);
      case MediaUrlStatus.failed:
        final error = widget.errorBuilder;
        return error != null ? error(context) : widget.builder(context, null);
    }
  }
}
