import '../services/iap_service.dart';

/// Single wording for the outcome of a "Restore Purchases" tap, shared by every
/// place that offers the control.
String restoreMessageFor(RestoreResult result) {
  if (!result.success) {
    return result.message ?? 'Purchases could not be restored.';
  }

  if (!result.restoredAnything) {
    return 'No previous purchases were found for this Apple ID.';
  }

  return result.restoredCount == 1
      ? 'Restored 1 previous purchase.'
      : 'Restored ${result.restoredCount} previous purchases.';
}
