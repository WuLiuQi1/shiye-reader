import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/reader/reader_leaf_status.dart';
import '../utils/glass_config.dart';
import '../utils/reader_themes.dart';
import 'reader_top_information_bar.dart';

typedef ReaderStatusBuilder =
    Widget Function(BuildContext context, TextStyle? style, Key? key);

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
    this.onChangeSource,
    this.changeSourceTooltip,
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
  final VoidCallback? onChangeSource;
  final String? changeSourceTooltip;
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
        AnimatedPositioned(
          key: topKey,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutQuart,
          left: 24,
          right: 24,
          top: visible ? 0 : -130,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 76),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: palette.secondaryText.withValues(alpha: .72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ReaderControlIconButton(
                      palette: palette,
                      onPressed: onBack,
                      tooltip: backTooltip,
                      icon: Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          key: bottomKey,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutQuart,
          right: 24,
          bottom: visible ? statusBottom + 8 : -180,
          child: SafeArea(
            top: false,
            child: _ReaderQuickMenu(
              palette: palette,
              title: title,
              onTableOfContents: onTableOfContents,
              onSettings: onSettings,
              onBookmark: bookmarkBusy ? null : onBookmark,
              onReadAloud: onReadAloud,
              onAskAi: onAskAi,
              onChangeSource: onChangeSource,
              tableOfContentsTooltip: tableOfContentsTooltip,
              settingsTooltip: settingsTooltip,
              bookmarkTooltip: bookmarkTooltip,
              bookmarked: bookmarked,
            ),
          ),
        ),
      ],
    );
  }
}

/// 阅读页只保留一个右下角入口。展开后用逐层上浮的操作卡替代传统底栏，
/// 让正文始终占据完整页面，交互层级与参考稿一致。
class _ReaderQuickMenu extends StatefulWidget {
  const _ReaderQuickMenu({
    required this.palette,
    required this.title,
    required this.onTableOfContents,
    required this.onSettings,
    required this.onBookmark,
    required this.onReadAloud,
    required this.onAskAi,
    required this.onChangeSource,
    required this.tableOfContentsTooltip,
    required this.settingsTooltip,
    required this.bookmarkTooltip,
    required this.bookmarked,
  });

  final ReaderThemePalette palette;
  final String title;
  final VoidCallback? onTableOfContents;
  final VoidCallback onSettings;
  final VoidCallback? onBookmark;
  final VoidCallback? onReadAloud;
  final VoidCallback? onAskAi;
  final VoidCallback? onChangeSource;
  final String tableOfContentsTooltip;
  final String settingsTooltip;
  final String bookmarkTooltip;
  final bool bookmarked;

  @override
  State<_ReaderQuickMenu> createState() => _ReaderQuickMenuState();
}

class _ReaderQuickMenuState extends State<_ReaderQuickMenu> {
  bool _expanded = false;

  void _run(VoidCallback? action) {
    setState(() => _expanded = false);
    action?.call();
  }

  @override
  Widget build(BuildContext context) {
    final panelColor = widget.palette.brightness == Brightness.dark
        ? const Color(0xED343438)
        : const Color(0xEE363638);
    final lightPanel = widget.palette.brightness == Brightness.dark
        ? const Color(0xE82B2B2F)
        : const Color(0xEEEEEFF2);
    return SizedBox(
      width: 286,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _animatedMenuItem(
                        index: 0,
                        child: _menuRow(
                        color: panelColor,
                        label: widget.tableOfContentsTooltip,
                        icon: Icons.format_list_bulleted_rounded,
                        foreground: Colors.white,
                        onTap: () => _run(widget.onTableOfContents),
                      ),
                      ),
                      const SizedBox(height: 10),
                      _animatedMenuItem(
                        index: 1,
                        child: _menuRow(
                        color: lightPanel,
                        label: '智能阅读助手',
                        icon: Icons.search_rounded,
                        foreground: widget.palette.text,
                        onTap: () => _run(widget.onAskAi),
                      ),
                      ),
                      const SizedBox(height: 10),
                      _animatedMenuItem(
                        index: 2,
                        child: _menuRow(
                        color: lightPanel,
                        label: widget.settingsTooltip,
                        icon: Icons.text_fields_rounded,
                        foreground: widget.palette.text,
                        onTap: () => _run(widget.onSettings),
                      ),
                      ),
                      const SizedBox(height: 10),
                      _animatedMenuItem(
                        index: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _smallButton(Icons.ios_share_rounded, widget.onChangeSource),
                            _smallButton(Icons.headphones_rounded, widget.onReadAloud),
                            _smallButton(Icons.format_list_bulleted_rounded, widget.onTableOfContents),
                            _smallButton(
                              widget.bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              widget.onBookmark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: '阅读菜单',
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: lightPanel,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.palette.border.withValues(alpha: .26),
                    ),
                  ),
                  child: Icon(
                    _expanded ? Icons.close_rounded : Icons.format_list_bulleted_rounded,
                    color: widget.palette.text,
                    size: 31,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required Color color,
    required String label,
    required IconData icon,
    required Color foreground,
    required VoidCallback onTap,
  }) => InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: onTap,
    child: Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w700))),
          Icon(icon, color: foreground, size: 29),
        ],
      ),
    ),
  );

  Widget _animatedMenuItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('reader-menu-item-$index'),
      duration: Duration(milliseconds: 180 + index * 45),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _smallButton(IconData icon, VoidCallback? onTap) => InkWell(
    borderRadius: BorderRadius.circular(31),
    onTap: onTap == null ? null : () => _run(onTap),
    child: Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(color: widget.palette.controlFill, shape: BoxShape.circle),
      child: Icon(icon, color: widget.palette.text, size: 28),
    ),
  );
}

class ReaderControlBar extends StatelessWidget {
  const ReaderControlBar({
    super.key,
    required this.palette,
    required this.isTopBar,
    required this.child,
  });

  final ReaderThemePalette palette;
  final bool isTopBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A reader toolbar is edge-to-edge and visually quiet. This deliberately
    // avoids the generic Flutter floating-card treatment.
    final borderRadius = BorderRadius.zero;
    final blurEnabled = !GlassEffectConfig.shouldDisableBlur;
    // 不叠加预设，直接使用与悬浮导航栏/首页顶栏一致的标准玻璃参数
    final config = GlassEffectHelper.getReadingControlConfig(
      isTopBar: isTopBar,
      brightness: palette.brightness,
    );
    final surfaceOpacity = blurEnabled ? config['opacity']! : 1.0;
    final cleanSurface = blurEnabled
        ? GlassEffectConfig.chromeBaseColor(
            palette.controlBar,
            palette.brightness,
            lightBlend: 0.28,
          )
        : palette.controlBar;
    final highlight = blurEnabled
        ? Color.lerp(
            cleanSurface,
            Colors.white,
            palette.brightness == Brightness.dark ? 0.06 : 0.1,
          )!
        : cleanSurface;
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: highlight.withValues(
          alpha: (surfaceOpacity + (blurEnabled ? 0.04 : 0.0)).clamp(0.0, 1.0),
        ),
        border: Border(
          bottom: isTopBar
              ? BorderSide(color: palette.border.withValues(alpha: 0.36), width: 0.5)
              : BorderSide.none,
          top: isTopBar
              ? BorderSide.none
              : BorderSide(color: palette.border.withValues(alpha: 0.36), width: 0.5),
        ),
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.045),
            blurRadius: 6,
            offset: Offset(0, isTopBar ? 3 : -3),
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
  });

  final ReaderThemePalette palette;
  final VoidCallback? onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final glassEnabled = !GlassEffectConfig.shouldDisableBlur;
    final cleanControlFill = glassEnabled
        ? GlassEffectConfig.chromeBaseColor(
            palette.controlFill,
            palette.brightness,
            lightBlend: 0.22,
          )
        : palette.controlFill;
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        foregroundColor: palette.text,
        backgroundColor: cleanControlFill.withValues(
          alpha: glassEnabled
              ? (palette.brightness == Brightness.light ? 0.76 : 0.58)
              : 1.0,
        ),
        minimumSize: const Size.square(42),
        maximumSize: const Size.square(42),
        padding: EdgeInsets.zero,
        side: BorderSide(
          color: glassEnabled
              ? Color.lerp(palette.border, Colors.white, 0.12)!.withValues(
                  alpha: palette.brightness == Brightness.light ? 0.28 : 0.48,
                )
              : palette.border,
          width: 0.8,
        ),
        shape: const CircleBorder(),
      ),
    );
  }
}
