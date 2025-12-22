# Project Feedback & Future Improvements

This document outlines the planned improvements, scaling strategies, and areas for further research for the Flutter Car Locator project.

## 🚀 Future Feature Roadmap

### 1. Real User Profiles (Firebase)
- **Authentication**: Transition from local storage to Firebase Authentication (Google, Email/Password).
- **Cloud Sync**: Store user preferences, saved car locations, and loyalty points in Firestore for multi-device synchronization.
- **Security**: Implement robust security rules to protect user location data.

### 2. Enhanced Location & Maps
- **Accuracy Improvements**: Integrate advanced location filtering (Kalman Filter) to handle GPS jitter.
- **Paid APIs**: Transition from free Overpass API mirrors to a dedicated paid provider (like Google Places API or Mapbox) to ensure 99.9% uptime and higher data accuracy.
- **Indoor Mapping**: Research indoor positioning for multi-story parking garages.

### 3. Advanced AR Car Locator
- **Realistic 3D Markers**: Replace simple icons with high-fidelity 3D car models or directional anchors.
- **Visual SLAM**: Spend more research time on visual mapping to provide centimeter-level accuracy for car placement in AR.
- **Persistent AR**: Use ARCore/ARKit cloud anchors to persist car locations across different app sessions more reliably.

## 📈 Scaling for Growth

### Codebase Organization
- **Micro-frontends / Packages**: As the app grows, split features into separate local packages to reduce build times and improve modularity.
- **Stronger DI**: Standardize dependency injection across all services to make testing easier.

### Performance Optimization
- **Caching Layer**: Implement a more robust caching strategy for network requests using `Dio` interceptors and local DB (Hive).
- **Image Optimization**: Implement dynamic image loading and caching for retail merchant logos.

### Dev-Ops & Testing
- **CI/CD**: Set up GitHub Actions for automated builds, linting, and unit testing.
- **Automated UI Tests**: Implement integration tests for critical flows like QR scanning and car anchoring.

## 🧪 Research Areas
- **AR Accuracy**: Deep dive into `arcore_flutter_plugin` and alternative AR solutions to mitigate drift in open spaces.
- **Battery Optimization**: Research low-power location tracking methods for background proximity alerts.
