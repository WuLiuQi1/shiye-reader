import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/reader/reader_leaf_status.dart';
import '../utils/glass_config.dart';
import '../utils/reader_themes.dart';
import 'reader_top_information_bar.dart';

typedef ReaderStatusBuilder =
    Widget Function(BuildContext context, TextStyle? style, Key? key);

/// Reader chrome intentionally mirrors the low-chrome interaction model used
/// by Apple Books: the page owns the screen, a tap reveals a close control in
/// the upper-right corner and a single reading menu in the lower-right.
class ReaderChromeOverlay extends StatelessWidget {
  const ReaderChromeOverlay({
    super.key,
    required this.palette,
    required this.visible,
    required this.title,
    required this.statusBottom,
    required this.statusBuilder,
    required this.onBack,
    required this.onBookmark,
    required this.onTableOfContents,
    required this.onSettings,
    required this.backTooltip,
    required this.bookmarkTooltip,
    required this.tableOfContentsTooltip,
    required this.settingsTooltip,
    required this.bookmarked,
    this.onReadAloud,
    this.readAloudTooltip,
    this.readAloudActive = false,
    this.onAskAi,
    this.askAiTooltip,
    this.bookmarkBusy = false,
    this.topKey,
    this.bottomKey,
    this.statusKey,
    this.showViewportStatus = true,
    this.showViewportTitle = false,
    this.viewportTitleTop = 0,
    this.viewportTitleKey,
    this.readerStatus,
    this.viewportStatusAlignment = Alignment.centerRight,
    this.viewportStatusHorizontalPadding = 14,
    this.showSettingsAction = true,
  });

  final ReaderThemePalette palette;
  final bool visible;
  final String title;
  final double statusBottom;
  final ReaderStatusBuilder statusBuilder;
  final VoidCallback onBack;
  final VoidCallback? onBookmark;
  final VoidCallback? onTableOfContents;
  final VoidCallback onSettings;
  final VoidCallback? onReadAloud;
  final VoidCallback? onAskAi;
  final String? askAiTooltip;
  final String backTooltip;
  final String bookmarkTooltip;
  final String tableOfContentsTooltip;
  final String settingsTooltip;
  final String? readAloudTooltip;
  final bool bookmarked;
  final bool readAloudActive;
  final bool bookmarkBusy;
  final Key? topKey;
  final Key? bottomKey;
  final Key? statusKey;
  final bool showViewportStatus;
  final bool showViewportTitle;
  final double viewportTitleTop;
  final Key? viewportTitleKey;
  final ReaderLeafStatusData? readerStatus;
  final AlignmentGeometry viewportStatusAlignment;
  final double viewportStatusHorizontalPadding;
  final bool showSettingsAction;

  void _openReadingMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.16),
      builder: (sheetContext) => _AppleBooksReadingMenu(
        palette: palette,
        title: title,
        bookmarked: bookmarked,
        bookmarkBusy: bookmarkBusy,
        onBookmark: onBookmark == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onBookmark?.call();
              },
        bookmarkTooltip: bookmarkTooltip,
        onTableOfContents: onTableOfContents == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onTableOfContents?.call();
              },
        tableOfContentsTooltip: tableOfContentsTooltip,
        onReadAloud: onReadAloud == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onReadAloud?.call();
              },
        readAloudTooltip: readAloudTooltip,
        readAloudActive: readAloudActive,
        onAskAi: onAskAi == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onAskAi?.call();
              },
        askAiTooltip: askAiTooltip,
        showSettingsAction: showSettingsAction,
        onSettings: () {
          Navigator.of(sheetContext).pop();
          onSettings();
        },
        settingsTooltip: settingsTooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showViewportTitle)
          Positioned(
            left: 30,
            right: 30,
            top: viewportTitleTop,
            child: IgnorePointer(
              child: AnimatedOpacity(
                key: viewportTitleKey,
                opacity: visible ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: ReaderTopInformationBar(
                  palette: palette,
                  title: title,
                  status: readerStatus,
                ),
              ),
            ),
          ),
        if (showViewportStatus)
          Positioned(
            left: 0,
            right: 0,
            bottom: statusBottom,
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: viewportStatusHorizontalPadding,
                ),
                child: Align(
                  alignment: viewportStatusAlignment,
                  child: statusBuilder(
                    context,
                    textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      height: 1,
                      color: palette.secondaryText.withValues(
                        alpha: visible ? 0 : 0.58,
                      ),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    statusKey,
                  ),
                ),
              ),
            ),
          ),
        if (!showViewportStatus && statusKey != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: statusBottom,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0,
                  child: statusBuilder(context, null, statusKey),
                ),
              ),
            ),
          ),

        // Apple Books keeps the reading surface visually quiet. The close
        // control floats on its own instead of living in a full-width bar.
        AnimatedPositioned(
          key: topKey,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: visible ? 10 : -82,
          right: 14,
          child: SafeArea(
            bottom: false,
            child: ReaderControlBar(
              palette: palette,
              isTopBar: true,
              compact: true,
              child: ReaderControlIconButton(
                palette: palette,
                onPressed: onBack,
                tooltip: backTooltip,
                icon: Icons.close_rounded,
                standalone: true,
              ),
            ),
          ),
        ),

        // A single menu button replaces the old four-action toolbar. All
        // reader actions remain available inside the menu sheet.
        AnimatedPositioned(
          key: bottomKey,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          right: 14,
          bottom: visible ? 12 : -90,
          child: SafeArea(
            top: false,
            child: ReaderControlBar(
              palette: palette,
              isTopBar: false,
              compact: true,
              child: ReaderControlIconButton(
                palette: palette,
                onPressed: () => _openReadingMenu(context),
                tooltip: settingsTooltip,
                icon: Icons.menu_rounded,
                standalone: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppleBooksReadingMenu extends StatelessWidget {
  const _AppleBooksReadingMenu({
    required this.palette,
    required this.title,
    required this.bookmarked,
    required this.bookmarkBusy,
    required this.onBookmark,
    required this.bookmarkTooltip,
    required this.onTableOfContents,
    required this.tableOfContentsTooltip,
    required this.onReadAloud,
    required this.readAloudTooltip,
    required this.readAloudActive,
    required this.onAskAi,
    required this.askAiTooltip,
    required this.showSettingsAction,
    required this.onSettings,
    required this.settingsTooltip,
  });

  final ReaderThemePalette palette;
  final String title;
  final bool bookmarked;
  final bool bookmarkBusy;
  final VoidCallback? onBookmark;
  final String bookmarkTooltip;
  final VoidCallback? onTableOfContents;
  final String tableOfContentsTooltip;
  final VoidCallback? onReadAloud;
  final String? readAloudTooltip;
  final bool readAloudActive;
  final VoidCallback? onAskAi;
  final String? askAiTooltip;
  final bool showSettingsAction;
  final VoidCallback onSettings;
  final String settingsTooltip;

  @override
  Widget build(BuildContext context) {
    final blurEnabled = !GlassEffectConfig.shouldDisableBlur;
    final base = GlassEffectConfig.chromeBaseColor(
      palette.controlBar,
      palette.brightness,
      lightBlend: 0.18,
    );
    final radius = BorderRadius.circular(30);
    final content = Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: palette.secondaryText.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            if (title.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            _ReadingMenuGroup(
              palette: palette,
              children: [
                if (onTableOfContents != null)
                  _ReadingMenuTile(
                    palette: palette,
                    icon: Icons.list_rounded,
                    label: tableOfContentsTooltip,
                    onTap: onTableOfContents!,
                  ),
                _ReadingMenuTile(
                  palette: palette,
                  icon: bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: bookmarkTooltip,
                  onTap: bookmarkBusy ? null : onBookmark,
                ),
              ],
            ),
            if (onReadAloud != null || onAskAi != null) ...[
              const SizedBox(height: 10),
              _ReadingMenuGroup(
                palette: palette,
                children: [
                  if (onReadAloud != null)
                    _ReadingMenuTile(
                      palette: palette,
                      icon: readAloudActive
                          ? Icons.graphic_eq_rounded
                          : Icons.headphones_rounded,
                      label: readAloudTooltip ?? '',
                      onTap: onReadAloud!,
                    ),
                  if (onAskAi != null)
                    _ReadingMenuTile(
                      palette: palette,
                      icon: Icons.auto_awesome_outlined,
                      label: askAiTooltip ?? '',
                      onTap: onAskAi!,
                    ),
                ],
              ),
            ],
            if (showSettingsAction) ...[
              const SizedBox(height: 10),
              _ReadingMenuGroup(
                palette: palette,
                children: [
                  _ReadingMenuTile(
                    palette: palette,
                    icon: Icons.text_fields_rounded,
                    label: settingsTooltip,
                    onTap: onSettings,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(
                alpha: palette.brightness == Brightness.dark ? 0.46 : 0.18,
              ),
              blurRadius: 34,
              spreadRadius: -8,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: blurEnabled
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: ColoredBox(
                    color: base.withValues(
                      alpha: palette.brightness == Brightness.dark ? 0.74 : 0.88,
                    ),
                    child: content,
                  ),
                )
              : ColoredBox(color: palette.controlBar, child: content),
        ),
      ),
    );
  }
}

class _ReadingMenuGroup extends StatelessWidget {
  const _ReadingMenuGroup({required this.palette, required this.children});

  final ReaderThemePalette palette;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: palette.controlFill.withValues(
          alpha: palette.brightness == Brightness.dark ? 0.44 : 0.62,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  indent: 52,
                  color: palette.border.withValues(alpha: 0.32),
                ),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadingMenuTile extends StatelessWidget {
  const _ReadingMenuTile({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final ReaderThemePalette palette;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minTileHeight: 50,
      minLeadingWidth: 28,
      horizontalTitleGap: 8,
      leading: Icon(icon, size: 21, color: palette.text),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: palette.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: palette.secondaryText.withValues(alpha: 0.72),
      ),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}

class ReaderControlBar extends StatelessWidget {
  const ReaderControlBar({
    super.key,
    required this.palette,
    required this.isTopBar,
    required this.child,
    this.compact = false,
  });

  final ReaderThemePalette palette;
  final bool isTopBar;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 999 : 28);
    final blurEnabled = !GlassEffectConfig.shouldDisableBlur;
    final config = GlassEffectHelper.getReadingControlConfig(
      isTopBar: isTopBar,
      brightness: palette.brightness,
    );
    final surfaceOpacity = blurEnabled ? config['opacity']! : 1.0;
    final cleanSurface = blurEnabled
        ? GlassEffectConfig.chromeBaseColor(
            palette.controlBar,
            palette.brightness,
            lightBlend: 0.22,
          )
        : palette.controlBar;
    final highlight = blurEnabled
        ? Color.lerp(
            cleanSurface,
            Colors.white,
            palette.brightness == Brightness.dark ? 0.06 : 0.14,
          )!
        : cleanSurface;
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            highlight.withValues(
              alpha: (surfaceOpacity + (blurEnabled ? 0.10 : 0.0)).clamp(0.0, 1.0),
            ),
            cleanSurface.withValues(
              alpha: (surfaceOpacity + (blurEnabled ? 0.02 : 0.0)).clamp(0.0, 1.0),
            ),
          ],
        ),
        border: Border.all(
          color: blurEnabled
              ? Colors.white.withValues(
                  alpha: palette.brightness == Brightness.light ? 0.42 : 0.16,
                )
              : palette.border,
          width: 0.7,
        ),
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(
              alpha: palette.brightness == Brightness.dark ? 0.34 : 0.16,
            ),
            blurRadius: 22,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: blurEnabled
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: config['blur']!,
                  sigmaY: config['blur']!,
                ),
                child: panel,
              )
            : panel,
      ),
    );
  }
}

class ReaderControlIconButton extends StatelessWidget {
  const ReaderControlIconButton({
    super.key,
    required this.palette,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    this.standalone = false,
  });

  final ReaderThemePalette palette;
  final VoidCallback? onPressed;
  final String tooltip;
  final IconData icon;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: standalone ? 21 : 22),
      style: IconButton.styleFrom(
        foregroundColor: palette.text,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: palette.secondaryText.withValues(alpha: 0.4),
        minimumSize: Size.square(standalone ? 46 : 44),
        maximumSize: Size.square(standalone ? 46 : 44),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
      ),
    );
  }
}
