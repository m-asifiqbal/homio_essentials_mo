/// ============================================================
/// CONNECTION REPOSITORY (contract) — "can this phone reach our server right now?"
/// ============================================================
///
/// Two separate questions, because they fail separately:
///   • does the phone have a network at all (Wi-Fi / mobile data on)?      → [hasNetwork], [networkChanges]
///   • does OUR server actually answer (Wi-Fi without internet, captive portal, outage)?  → [serverReachable]
/// The connection ViewModel combines them; nothing here knows about widgets.
/// ============================================================
library;

abstract interface class ConnectionRepository {
  /// Fires whenever the phone's network changes (Wi-Fi ↔ mobile data ↔ none). The value carries no meaning:
  /// ask [hasNetwork] after it fires.
  Stream<void> get networkChanges;

  /// False when the phone has no network at all (airplane mode, Wi-Fi and mobile data both off).
  Future<bool> hasNetwork();

  /// True when our server answers. ANY answer counts — even an error status means "reachable"; only a failed or
  /// timed-out connection is false. Never throws.
  Future<bool> serverReachable();
}
