/// Roles resmi backend. UI hanya presentation; backend otoritatif.
// ignore_for_file: avoid_classes_with_only_static_members
abstract final class Roles {
  static const superAdmin = 'super_admin';
  static const admin = 'admin';
  static const manager = 'manager';
  static const kasir = 'kasir';
  static const mekanik = 'mekanik';
  static const advisor = 'service_advisor';
  static const inventory = 'inventory';

  static bool unrestricted(List<String> r) =>
      r.contains(superAdmin) || r.contains(admin);

  static bool canApproveEstimate(List<String> r) =>
      unrestricted(r) || r.contains(manager) || r.contains(advisor);
  static bool canConvertEstimate(List<String> r) =>
      unrestricted(r) || r.contains(manager);
  static bool canDriveTask(List<String> r) =>
      unrestricted(r) ||
      r.contains(manager) ||
      r.contains(advisor) ||
      r.contains(mekanik);
  static bool canQc(List<String> r) => canApproveEstimate(r);
  static bool canPay(List<String> r) =>
      unrestricted(r) || r.contains(manager) || r.contains(kasir);
  static bool canManageStock(List<String> r) =>
      unrestricted(r) || r.contains(manager) || r.contains(inventory);
}
