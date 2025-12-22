class AppConstants {
  // App Information
  static const String appName = 'AR Car Locator';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String carAnchorKey = 'car_anchor';
  static const String userDataKey = 'user_data';
  static const String groceryListKey = 'grocery_list';
  static const String allGroceryListsKey = 'all_grocery_lists';
  static const String activeGroceryListIdKey = 'active_grocery_list_id';
  static const String claimedRewardsKey = 'claimed_rewards';

  // Location Settings
  static const double defaultLocationAccuracy = 10.0;
  static const int locationUpdateInterval = 5000; // milliseconds
  static const double carSearchRadius = 1000.0; // meters

  // AR Settings
  static const double arObjectScale = 1.0;
  static const double compassSensitivity = 5.0; // degrees

  // Campaign Settings
  static const double campaignVisibilityRadius = 500.0; // meters
  static const int maxNearbyPins = 20;

  // Notification Settings
  static const String notificationChannelId = 'car_locator_notifications';
  static const String notificationChannelName = 'Car Locator Notifications';
  static const String notificationChannelDescription =
      'Notifications for car location and campaigns';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // Map Settings
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 10.0;

  // QR Code Settings
  static const String qrCodePrefix = 'CAR_LOCATOR_';
  static const int qrCodeVersion = 1;
}

class AppColors {
  // Primary Colors
  static const primaryColor = 0xFF2196F3;
  static const primaryColorDark = 0xFF1976D2;
  static const primaryColorLight = 0xFF64B5F6;

  // Secondary Colors
  static const accentColor = 0xFF4CAF50;
  static const accentColorDark = 0xFF388E3C;
  static const accentColorLight = 0xFF81C784;

  // Status Colors
  static const successColor = 0xFF4CAF50;
  static const warningColor = 0xFFFF9800;
  static const errorColor = 0xFFF44336;
  static const infoColor = 0xFF2196F3;

  // Neutral Colors
  static const whiteColor = 0xFFFFFFFF;
  static const blackColor = 0xFF000000;
  static const greyColor = 0xFF9E9E9E;
  static const lightGreyColor = 0xFFE0E0E0;
  static const darkGreyColor = 0xFF424242;

  // Campaign Type Colors
  static const retailColor = 0xFF9C27B0;
  static const foodColor = 0xFFFF5722;
  static const entertainmentColor = 0xFFE91E63;
  static const gasColor = 0xFF607D8B;
  static const shoppingColor = 0xFF3F51B5;
  static const exclusiveColor = 0xFFFFD700;
}

class AppStrings {
  // App General
  static const String appTitle = 'AR Car Locator';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String done = 'Done';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';

  // Car Locator
  static const String markCarLocation = 'Mark Car Location';
  static const String findMyCar = 'Find My Car';
  static const String carLocationSaved = 'Car location saved successfully';
  static const String noCarLocationFound = 'No car location found';
  static const String carLocationCleared = 'Car location cleared';
  static const String navigatingToCar = 'Navigating to your car...';

  // AR Mode
  static const String arMode = 'AR Mode';
  static const String arCarLocatorTitle = 'AR Car Locator';
  static const String switchToMapMode = 'Switch to Map Mode';
  static const String switchToArMode = 'Switch to AR Mode';
  static const String arNotSupported = 'AR not supported on this device';
  static const String noCarMarked = 'No car location marked';

  // Campaigns
  static const String nearbyCampaigns = 'Nearby Campaigns';
  static const String campaignDetails = 'Campaign Details';
  static const String claimReward = 'Claim Reward';
  static const String rewardClaimed = 'Reward claimed successfully';
  static const String alreadyClaimed = 'Already claimed';
  static const String loyaltyRequired = 'Loyalty level required';

  // Grocery List
  static const String groceryList = 'Grocery List';
  static const String sendToValet = 'Send to Valet';
  static const String groceryListSentToValet = 'Grocery list sent to valet';
  static const String addGroceryItem = 'Add Grocery Item';

  // QR Code
  static const String scanQrCode = 'Scan QR Code';
  static const String qrCodeScanned = 'QR Code scanned successfully';
  static const String invalidQrCode = 'Invalid QR code';

  // Permissions
  static const String locationPermissionRequired =
      'Location permission required';
  static const String cameraPermissionRequired = 'Camera permission required';
  static const String permissionDenied = 'Permission denied';

  // Navigation
  static const String home = 'Home';
  static const String map = 'Map';
  static const String arView = 'AR View';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
}
