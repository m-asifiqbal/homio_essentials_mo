/// ============================================================
/// REVEAL BOTTOM NAV NOTIFICATION
/// ============================================================
///
/// Dispatched by a descendant that has just moved a list on the user's behalf
/// (the scroll-to-top pill), to ask the enclosing `AppShell` to bring its
/// auto-hiding bottom bar back. A `Notification` bubbles up the same path the
/// shell already listens on, needs no wiring, and is inert when no shell is
/// above (a pushed page can dispatch it harmlessly).
///
/// Same idea as mgi_recruitment's `RevealBottomNavNotification`.
/// ============================================================
library;

import 'package:flutter/widgets.dart';

class RevealBottomNavNotification extends Notification {
  const RevealBottomNavNotification();
}
