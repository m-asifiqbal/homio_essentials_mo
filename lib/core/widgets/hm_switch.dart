/// ============================================================
/// HM SWITCH — iOS-style switch on every platform (FocusFlow's `FFSwitch`)
/// ============================================================
library;

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoSwitch;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

class HmSwitch extends StatelessWidget {
  const HmSwitch({super.key, required this.value, required this.onChanged, this.semanticLabel});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Semantics(
      label: semanticLabel,
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged == null ? null : (v) { HapticFeedback.selectionClick(); onChanged!(v); },
        activeTrackColor: c.p,
        inactiveTrackColor: c.ink.withValues(alpha: c.dark ? 0.16 : 0.10),
        thumbColor: c.dark && value ? c.onp : Colors.white,
      ),
    );
  }
}
