import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class FloatingTab {
  const FloatingTab({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

// 하단 메뉴(2026-10-22 사용자 요청, 인스타그램 느낌): 화면 아래에 떠 있는 둥근 캡슐 안에 아이콘 + 작은 글자.
// 선택 칸(연한 회색 surfaceContainer 둥근 칸)은 하나만 두고, 다른 탭을 고르면 새 탭 자리로 미끄러지듯 옮긴다
// (2026-10-22 사용자 녹화: 앞쪽 끝이 먼저 가고 뒤쪽 끝이 따라와 가는 동안 늘어났다가 줄어든다). 아이콘·글자는 고른 순간 바뀐다.
// 캡슐 위를 좌우로 끌면 선택 칸이 손가락을 따라가고, 놓은 자리의 탭을 고른다. 동작 줄이기 설정이면 바로 옮긴다.
// 글자를 키우면 캡슐도 함께 높아진다. 낭독은 Material NavigationBar처럼 '이름 + Tab n of N'을 한 버튼으로 읽고 선택 상태를 알린다.
class FloatingTabBar extends StatefulWidget {
  const FloatingTabBar({super.key, required this.tabs, required this.selectedIndex, required this.onSelected});

  // 선택 칸이 옮겨 가는 시간. DS photoPaging(250ms)보다 조금 길게 두어 늘어났다 줄어드는 모양이 보이게 한다.
  static const moveDuration = Duration(milliseconds: 350);

  final List<FloatingTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FloatingTabBar> createState() => _FloatingTabBarState();
}

class _FloatingTabBarState extends State<FloatingTabBar> with SingleTickerProviderStateMixin {
  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: FloatingTabBar.moveDuration,
    value: 1,
  );

  // 선택 칸의 왼쪽·오른쪽 끝(탭 너비 단위). 탭 i의 자리는 [i, i + 1]이다.
  late double _fromLeft = widget.selectedIndex.toDouble();
  late double _fromRight = _fromLeft + 1;
  late double _toLeft = _fromLeft;
  late double _toRight = _fromRight;
  double? _dragCenter; // 끄는 중이면 손가락 아래 칸의 가운데(탭 너비 단위)

  @override
  void didUpdateWidget(FloatingTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex && widget.selectedIndex.toDouble() != _toLeft) {
      _slideTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  // 지금 선택 칸의 두 끝. 움직이는 동안은 앞쪽 끝이 빠른 곡선, 뒤쪽 끝이 느린 곡선을 따라가 칸이 늘어났다가 줄어든다.
  (double, double) _edges() {
    final drag = _dragCenter;
    if (drag != null) return (drag - 0.5, drag + 0.5);
    final t = _move.value;
    final lead = Curves.easeOutCubic.transform(t);
    final trail = Curves.easeInOutCubic.transform(t);
    final movingRight = _toLeft > _fromLeft;
    return (
      _fromLeft + (_toLeft - _fromLeft) * (movingRight ? trail : lead),
      _fromRight + (_toRight - _fromRight) * (movingRight ? lead : trail),
    );
  }

  // 지금 칸 위치(움직이는 중이거나 끄는 중이면 그 순간 위치)에서 탭 [index] 자리로 옮긴다.
  void _slideTo(int index) {
    final (left, right) = _edges();
    _fromLeft = left;
    _fromRight = right;
    _toLeft = index.toDouble();
    _toRight = index + 1.0;
    _dragCenter = null;
    if (MediaQuery.of(context).disableAnimations) {
      _move.value = 1;
    } else {
      _move.forward(from: 0);
    }
  }

  void _dragTo(double dx, double tabWidth) {
    _move.stop();
    setState(() => _dragCenter = (dx / tabWidth).clamp(0.5, widget.tabs.length - 0.5));
  }

  // 손을 떼면 칸 가운데가 가장 가까운 탭을 고르고 그 자리로 옮긴다. 원래 탭이면 고르지 않는다(맨 위로 올리기 없음).
  void _dragEnd() {
    final center = _dragCenter;
    if (center == null) return;
    final index = (center - 0.5).round().clamp(0, widget.tabs.length - 1);
    setState(() => _slideTo(index));
    if (index != widget.selectedIndex) widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tabs = widget.tabs;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, AppSpace.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.navBar),
          padding: const EdgeInsets.all(AppSpace.fieldGap),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: c.divider),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 4))],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / tabs.length;
              return GestureDetector(
                excludeFromSemantics: true, // 낭독에서는 탭 버튼만(끌기는 손가락 동작)
                onHorizontalDragStart: (d) => _dragTo(d.localPosition.dx, tabWidth),
                onHorizontalDragUpdate: (d) => _dragTo(d.localPosition.dx, tabWidth),
                onHorizontalDragEnd: (_) => _dragEnd(),
                onHorizontalDragCancel: _dragEnd,
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _move,
                        builder: (context, _) {
                          final (left, right) = _edges();
                          return Positioned(
                            left: left * tabWidth,
                            width: (right - left) * tabWidth,
                            top: 0,
                            bottom: 0,
                            child: DecoratedBox(
                              key: const ValueKey('tab-pill'),
                              decoration: ShapeDecoration(color: c.surfaceContainer, shape: const StadiumBorder()),
                            ),
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < tabs.length; i++)
                            Expanded(
                              child: _TabItem(
                                tab: tabs[i],
                                selected: i == widget.selectedIndex,
                                semanticsLabel:
                                    '${tabs[i].label}\n${MaterialLocalizations.of(context).tabLabel(tabIndex: i + 1, tabCount: tabs.length)}',
                                onTap: () => widget.onSelected(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.selected, required this.semanticsLabel, required this.onTap});

  final FloatingTab tab;
  final bool selected;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const shape = StadiumBorder();
    // 선택 칸은 FloatingTabBar가 하나만 그려 옮기므로 탭은 투명 바탕이다. 누를 때 색이 바뀌는 물결·눌림 색도 두지 않는다
    // (2026-10-22 사용자 요청: 지금 탭은 선택 칸으로 구분된다). 키보드 초점 표시는 남긴다.
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minimumTap),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.fieldGap),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(selected ? tab.selectedIcon : tab.icon, color: selected ? c.textPrimary : c.textSecondary),
                  const SizedBox(height: 2),
                  Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? c.textPrimary : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
