import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Un élément de fil d’Ariane.
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });

  bool get isClickable => onTap != null;
}

class AppBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  /// Séparateur entre éléments (ex: " → ").
  final Widget? separator;

  /// Style des éléments cliquables (non-dernier).
  final TextStyle? inactiveTextStyle;

  /// Style au hover pour les éléments cliquables (non-dernier).
  /// Si null -> fallback sur inactiveTextStyle.
  final TextStyle? inactiveHoverTextStyle;

  /// Style de l’élément courant (dernier).
  final TextStyle? activeTextStyle;

  /// Style au hover pour l’élément courant (si jamais tu le rends cliquable).
  /// Si null -> fallback sur activeTextStyle.
  final TextStyle? activeHoverTextStyle;

  /// Couleur du feedback (InkWell).
  final Color? splashColor;
  final Color? highlightColor;

  /// Si true: scroll horizontal (évite les overflows).
  /// Si false: wrap sur plusieurs lignes.
  final bool scrollable;

  /// Padding autour du breadcrumb.
  final EdgeInsetsGeometry padding;

  /// Contraint chaque label à 1 ligne + ellipsis.
  final int maxLinesPerItem;

  /// Désactive les taps (mode readOnly).
  final bool readOnly;

  const AppBreadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.inactiveTextStyle,
    this.inactiveHoverTextStyle,
    this.activeTextStyle,
    this.activeHoverTextStyle,
    this.splashColor,
    this.highlightColor,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
    this.maxLinesPerItem = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final sep = separator ??
        Text(
          ' → ',
          style: theme.textTheme.labelMedium,
        );

    final inactiveStyle = inactiveTextStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final inactiveHoverStyle = inactiveHoverTextStyle ?? inactiveStyle;

    final activeStyle = activeTextStyle ?? theme.textTheme.labelMedium ?? const TextStyle();
    final activeHoverStyle = activeHoverTextStyle ?? activeStyle;

    final children = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // Par défaut : le dernier n'est pas cliquable.
      final canTap = !readOnly && !isLast && item.onTap != null;

      final w = _BreadcrumbLabel(
        label: item.label,
        maxLines: maxLinesPerItem,
        onTap: canTap ? item.onTap : null,
        normalStyle: isLast ? activeStyle : inactiveStyle,
        hoverStyle: isLast ? activeHoverStyle : inactiveHoverStyle,
        splashColor: splashColor,
        highlightColor: highlightColor,
      );

      // Important: pour ellipsis correct en Row
      children.add(
        Flexible(
          fit: FlexFit.loose,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 0),
            child: w,
          ),
        ),
      );

      if (!isLast) {
        children.add(sep);
      }
    }

    final content = scrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          )
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _unwrapFlexible(children),
          );

    return Padding(
      padding: padding,
      child: content,
    );
  }

  /// Wrap n'aime pas les Flexible.
  /// On convertit: Flexible(child: X) -> X, et on garde les séparateurs.
  List<Widget> _unwrapFlexible(List<Widget> widgets) {
    return widgets.map((w) {
      if (w is Flexible) return w.child ?? const SizedBox.shrink();
      return w;
    }).toList();
  }
}

class _BreadcrumbLabel extends StatefulWidget {
  final String label;
  final int maxLines;

  final VoidCallback? onTap;

  final TextStyle normalStyle;
  final TextStyle hoverStyle;

  final Color? splashColor;
  final Color? highlightColor;

  const _BreadcrumbLabel({
    required this.label,
    required this.maxLines,
    required this.onTap,
    required this.normalStyle,
    required this.hoverStyle,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<_BreadcrumbLabel> createState() => _BreadcrumbLabelState();
}

class _BreadcrumbLabelState extends State<_BreadcrumbLabel> {
  bool _hovered = false;

  bool get _isHoverCapable =>
      kIsWeb ||
      {
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform);

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;
    final style = (clickable && _hovered) ? widget.hoverStyle : widget.normalStyle;

    Widget text = Text(
      widget.label,
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    if (!clickable) {
      return text;
    }

    // InkWell gère le tap + hover (sur web/desktop)
    text = InkWell(
      onTap: widget.onTap,
      splashColor: widget.splashColor,
      highlightColor: widget.highlightColor,
      onHover: _isHoverCapable
          ? (v) {
              if (_hovered == v) return;
              setState(() => _hovered = v);
            }
          : null,
      child: text,
    );

    // Bonus: curseur "click" au hover
    if (_isHoverCapable) {
      text = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: text,
      );
    }

    return text;
  }
}
