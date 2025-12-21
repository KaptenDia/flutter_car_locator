// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbyCampaignsHash() => r'4eeb03af79ae95c51cceae859441198192276d74';

/// See also [nearbyCampaigns].
@ProviderFor(nearbyCampaigns)
final nearbyCampaignsProvider =
    AutoDisposeProvider<List<CampaignPinModel>>.internal(
      nearbyCampaigns,
      name: r'nearbyCampaignsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nearbyCampaignsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NearbyCampaignsRef = AutoDisposeProviderRef<List<CampaignPinModel>>;
String _$campaignNotifierHash() => r'12e75f8101ee244b990a8513b63f1194a0ce214c';

/// See also [CampaignNotifier].
@ProviderFor(CampaignNotifier)
final campaignNotifierProvider =
    AutoDisposeNotifierProvider<
      CampaignNotifier,
      List<CampaignPinModel>
    >.internal(
      CampaignNotifier.new,
      name: r'campaignNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$campaignNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CampaignNotifier = AutoDisposeNotifier<List<CampaignPinModel>>;
String _$selectedCampaignNotifierHash() =>
    r'1c10e855a59b9428b669dd835072ae8d0dfd0a26';

/// See also [SelectedCampaignNotifier].
@ProviderFor(SelectedCampaignNotifier)
final selectedCampaignNotifierProvider =
    AutoDisposeNotifierProvider<
      SelectedCampaignNotifier,
      CampaignPinModel?
    >.internal(
      SelectedCampaignNotifier.new,
      name: r'selectedCampaignNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCampaignNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCampaignNotifier = AutoDisposeNotifier<CampaignPinModel?>;
String _$claimedRewardsNotifierHash() =>
    r'12d71d31f7154b6332bd392c754e248f6381f1a8';

/// See also [ClaimedRewardsNotifier].
@ProviderFor(ClaimedRewardsNotifier)
final claimedRewardsNotifierProvider =
    AutoDisposeNotifierProvider<ClaimedRewardsNotifier, List<String>>.internal(
      ClaimedRewardsNotifier.new,
      name: r'claimedRewardsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$claimedRewardsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClaimedRewardsNotifier = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
