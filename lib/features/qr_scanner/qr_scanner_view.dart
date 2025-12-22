import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/providers.dart';
import '../retail_discovery/campaign_detail_view.dart';

class QrScannerView extends ConsumerStatefulWidget {
  const QrScannerView({super.key});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Code Scanner'),
          backgroundColor: const Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                AppStrings.cameraPermissionRequired,
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              controller?.getFlashStatus() == true
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color(AppColors.primaryColor),
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),

          // Top overlay with instructions
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(179), Colors.transparent],
                ),
              ),
              child: const Text(
                'Position the QR code within the frame to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Bottom overlay with controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(179), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'pause_resume',
                        onPressed: () {
                          setState(() {
                            if (isScanning) {
                              controller?.pauseCamera();
                            } else {
                              controller?.resumeCamera();
                            }
                            isScanning = !isScanning;
                          });
                        },
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(AppColors.primaryColor),
                        child: Icon(
                          isScanning ? Icons.pause : Icons.play_arrow,
                        ),
                      ),

                      FloatingActionButton(
                        heroTag: 'flip_camera',
                        onPressed: () async {
                          await controller?.flipCamera();
                        },
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(AppColors.primaryColor),
                        child: const Icon(Icons.flip_camera_ios),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Scan campaign QR codes to claim exclusive rewards',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Scanning indicator
          if (isScanning)
            const Positioned(top: 100, right: 20, child: _ScanningIndicator()),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && isScanning) {
        _handleQrCodeScanned(scanData.code!);
      }
    });
  }

  void _handleQrCodeScanned(String qrCode) {
    // Pause scanning to prevent multiple scans
    controller?.pauseCamera();
    setState(() {
      isScanning = false;
    });

    // Validate QR code format
    if (qrCode.startsWith(AppConstants.qrCodePrefix)) {
      _processValidQrCode(qrCode);
    } else {
      _showInvalidQrCodeDialog();
    }
  }

  void _processValidQrCode(String qrCode) {
    // Extract campaign/reward ID from QR code
    final code = qrCode.substring(AppConstants.qrCodePrefix.length);

    // Process based on code type
    if (code.startsWith('CAMPAIGN_')) {
      _processCampaignQrCode(code);
    } else if (code.startsWith('REWARD_')) {
      _processRewardQrCode(code);
    } else {
      _showInvalidQrCodeDialog();
    }
  }

  void _processCampaignQrCode(String campaignCode) {
    // Find campaign by ID
    final campaigns = ref.read(campaignNotifierProvider);
    final campaignId = campaignCode.substring('CAMPAIGN_'.length);
    final campaign = campaigns.cast<CampaignPinModel?>().firstWhere(
      (c) => c?.id == campaignId,
      orElse: () => null,
    );

    if (campaign != null) {
      _showCampaignQrResultDialog(campaign);
    } else {
      _showInvalidQrCodeDialog();
    }
  }

  void _processRewardQrCode(String rewardCode) {
    // Extract reward ID and attempt to claim
    final rewardId = rewardCode.substring('REWARD_'.length);

    // Find the reward across all campaigns
    final campaigns = ref.read(campaignNotifierProvider);
    CampaignPinModel? targetCampaign;
    RewardModel? targetReward;

    for (final campaign in campaigns) {
      for (final reward in campaign.rewards) {
        if (reward.id == rewardId) {
          targetCampaign = campaign;
          targetReward = reward;
          break;
        }
      }
      if (targetReward != null) break;
    }

    if (targetReward != null && targetCampaign != null) {
      _claimRewardFromQr(targetCampaign, targetReward);
    } else {
      _showInvalidQrCodeDialog();
    }
  }

  Future<void> _claimRewardFromQr(
    CampaignPinModel campaign,
    RewardModel reward,
  ) async {
    final user = ref.read(userNotifierProvider);

    // Check if user can claim the reward
    if (user == null) {
      _showErrorDialog('Please log in to claim rewards');
      return;
    }

    // Check loyalty level requirement
    if (reward.requiredLoyaltyLevel != null) {
      final loyaltyLevels = LoyaltyLevel.values;
      final requiredIndex = loyaltyLevels.indexOf(reward.requiredLoyaltyLevel!);
      final userIndex = loyaltyLevels.indexOf(user.loyaltyLevel);

      if (userIndex < requiredIndex) {
        _showErrorDialog(
          'This reward requires ${reward.requiredLoyaltyLevel!.name.toUpperCase()} '
          'loyalty level. Your current level: ${user.loyaltyLevel.name.toUpperCase()}',
        );
        return;
      }
    }

    // Check if already claimed
    final claimedRewards = ref.read(claimedRewardsNotifierProvider);
    if (claimedRewards.contains(reward.id)) {
      _showErrorDialog('You have already claimed this reward');
      return;
    }

    // Claim the reward
    await ref
        .read(claimedRewardsNotifierProvider.notifier)
        .claimReward(reward.id);

    // Add loyalty points
    await ref.read(userNotifierProvider.notifier).addLoyaltyPoints(15);

    _showRewardClaimedDialog(campaign, reward);
  }

  void _showCampaignQrResultDialog(CampaignPinModel campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.qr_code_scanner,
              color: Color(AppColors.successColor),
            ),
            const SizedBox(width: 8),
            const Text('QR Code Scanned'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(campaign.description),
            const SizedBox(height: 12),
            Text(
              '${campaign.rewards.length} reward${campaign.rewards.length != 1 ? 's' : ''} available',
              style: const TextStyle(
                color: Color(AppColors.successColor),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: const Text('Continue Scanning'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CampaignDetailView(campaign: campaign),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('View Campaign'),
          ),
        ],
      ),
    );
  }

  void _showRewardClaimedDialog(CampaignPinModel campaign, RewardModel reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(AppColors.successColor)),
            SizedBox(width: 8),
            Text('Reward Claimed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(reward.description),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.successColor).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(AppColors.successColor)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.stars, color: Color(AppColors.successColor)),
                  SizedBox(width: 8),
                  Text(
                    '+15 Loyalty Points Earned!',
                    style: TextStyle(
                      color: Color(AppColors.successColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: const Text('Scan More'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.successColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showInvalidQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(AppColors.errorColor)),
            SizedBox(width: 8),
            Text('Invalid QR Code'),
          ],
        ),
        content: const Text(
          '${AppStrings.invalidQrCode}\n\nPlease scan a valid campaign or reward QR code.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(AppColors.errorColor)),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    controller?.resumeCamera();
    setState(() {
      isScanning = true;
    });
  }
}

class _ScanningIndicator extends StatefulWidget {
  const _ScanningIndicator();

  @override
  State<_ScanningIndicator> createState() => __ScanningIndicatorState();
}

class __ScanningIndicatorState extends State<_ScanningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(AppColors.primaryColor),
                    const Color(AppColors.successColor),
                    _animation.value,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Scanning...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}
