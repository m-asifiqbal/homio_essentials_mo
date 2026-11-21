/// ============================================================
/// HM SEARCH LAUNCHER — the tappable search bar on Home / Explore
/// ============================================================
///
/// Looks like a field, opens the search screen; the mic opens it straight
/// into voice mode (design: `.search` with `.mic`).
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

class SearchLauncher extends StatelessWidget {
  const SearchLauncher({
    super.key,
    required this.hint,
    required this.onTap,
    this.onVoice,
    this.height = 56,
  });
  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onVoice;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: c.cardShadow,
      ),
      child: Material(
        color: c.sf,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.ln),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(Icons.search_rounded, color: c.ink3),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.ink3, fontSize: 15),
                  ),
                ),
                if (onVoice != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 7),
                    child: Material(
                      color: c.sf2,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onVoice,
                        child: Tooltip(
                          message: context.l.voiceSearch,
                          child: SizedBox(
                            width: height - 14,
                            height: height - 14,
                            child: Icon(Icons.mic_none_rounded, color: c.pd),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
