class Routes {
  // Auth routes
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Doctor routes (main app)
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorCapture = '/doctor/capture';
  static const String doctorScreenings = '/doctor/screenings';
  static const String doctorScreeningDetail = '/doctor/screening/:id';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorSettings = '/doctor/settings';
  static const String doctorEditProfile = '/doctor/edit-profile';
  static const String doctorHelp = '/doctor/help';

  // Shared route names
  static const String dashboard = 'dashboard';
  static const String capture = 'capture';
  static const String screenings = 'screenings';
  static const String screeningDetail = 'screening-detail';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String editProfile = 'edit-profile';
  static const String help = 'help';
}
