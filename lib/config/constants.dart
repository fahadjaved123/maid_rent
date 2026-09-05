class AppConstants {
  // Service types offered by maids
  static const List<String> serviceTypes = [
    'House Cleaning',
    'Laundry',
    'Ironing',
    'Cooking',
    'Dishwashing',
    'Babysitting',
    'Elder Care',
    'Gardening',
    'Grocery Shopping',
    'Pet Care',
  ];

  // Working days
  static const List<String> weekDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // Languages
  static const List<String> languages = [
    'English', 'Hindi', 'Urdu', 'Punjabi', 'Bengali',
    'Tamil', 'Telugu', 'Marathi', 'Gujarati', 'Kannada',
  ];

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String maidProfilesCollection = 'maid_profiles';
  static const String bookingsCollection = 'bookings';
  static const String hourlyPostsCollection = 'hourly_posts';
  static const String reviewsCollection = 'reviews';
  static const String verificationsCollection = 'verifications';


  // Storage paths
  static const String profileImagesPath = 'profile_images';
}
