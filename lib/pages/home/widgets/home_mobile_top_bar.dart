// 文件说明：移动端首页顶部栏组件，承载品牌展示与顶部操作入口。
// 技术要点：Flutter UI、渲染层。

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:xxread/utils/glass_config.dart';

import '../home_mobile_chrome.dart';

/// 手机首页顶部标题栏。使用 iOS 阅读应用常见的大标题和半透明分隔层级。
///
/// 只负责显示标题和视觉样式，不处理页面业务逻辑。
class HomeMobileTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double horizontalPadding;

  const HomeMobileTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.titleFontSize = 40,
    this.titleFontWeight = FontWeight.w800,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final metrics = HomeMobileChromeScope.of(context);
    final isDark = scheme.brightness == Brightness.dark;
    final useBlur = !GlassEffectConfig.shouldDisableBlur;
    final content = Container(
      height: metrics.topBarHeight,
      decoration: BoxDecoration(
        // The screenshot's header is visually part of the page rather than a
        // separate Material app bar.  Keep it clean; sheets provide borders.
        color: (isDark ? const Color(0xF2000000) : const Color(0xF2FFFFFF)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          metrics.systemTopInset + 12,
          horizontalPadding,
          8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  height: 1.05,
                  letterSpacing: -1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );

    return ClipRRect(
      child: useBlur
          ? BackdropFilter(
              enabled: useBlur,
              filter: ImageFilter.blur(
                sigmaX: GlassEffectConfig.appBarBlur,
                sigmaY: GlassEffectConfig.appBarBlur,
              ),
              child: content,
            )
          : content,
    );
  }
}
