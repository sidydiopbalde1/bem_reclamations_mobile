abstract final class AppRoutes {
  static const login = '/login';
  static const reclamations = '/reclamations';
  static const newReclamation = '/reclamations/new';
  static const reclamationDetailPattern = '/reclamations/:id';
  static const profile = '/profile';
  static const admin = '/admin';

  static String reclamationDetail(String id) => '/reclamations/$id';
}
