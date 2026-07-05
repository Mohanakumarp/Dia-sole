import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/foot_pressure_widget.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/sync_card.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_data_provider.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const AnalyticsScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          100,
        ), // Bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            const SyncCard(),
            const SizedBox(height: 24),
            _buildActiveAnalysisCard(),
            const SizedBox(height: 24),
            _buildMedicalInsightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "DiaSole",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.battery_charging_full_rounded,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 4),
            const Text(
              "78%",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.bluetooth_connected_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAnalysisCard() {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        final leftPressures = provider.getPressures(DeviceSide.left);
        final leftTemps = provider.getTemperatures(DeviceSide.left);
        final rightPressures = provider.getPressures(DeviceSide.right);
        final rightTemps = provider.getTemperatures(DeviceSide.right);

        // Use live values from Firebase, 0.0 when no data available
        final pressureLeftHeel =
            leftPressures != null && leftPressures.isNotEmpty
            ? leftPressures[0]
            : 0.0;
        final pressureLeftBall =
            leftPressures != null && leftPressures.length > 1
            ? leftPressures[1]
            : 0.0;
        final pressureLeftToe =
            leftPressures != null && leftPressures.length > 2
            ? leftPressures[2]
            : 0.0;
        final pressureLeftOppositeHeel =
            leftPressures != null && leftPressures.length > 3
            ? leftPressures[3]
            : 0.0;
        final pressureLeftOppositeBall =
            leftPressures != null && leftPressures.length > 4
            ? leftPressures[4]
            : 0.0;
        final pressureLeftOppositeToe =
            leftPressures != null && leftPressures.length > 5
            ? leftPressures[5]
            : 0.0;

        final pressureRightHeel =
            rightPressures != null && rightPressures.isNotEmpty
            ? rightPressures[0]
            : 0.0;
        final pressureRightBall =
            rightPressures != null && rightPressures.length > 1
            ? rightPressures[1]
            : 0.0;
        final pressureRightToe =
            rightPressures != null && rightPressures.length > 2
            ? rightPressures[2]
            : 0.0;
        final pressureRightOppositeHeel =
            rightPressures != null && rightPressures.length > 3
            ? rightPressures[3]
            : 0.0;
        final pressureRightOppositeBall =
            rightPressures != null && rightPressures.length > 4
            ? rightPressures[4]
            : 0.0;
        final pressureRightOppositeToe =
            rightPressures != null && rightPressures.length > 5
            ? rightPressures[5]
            : 0.0;

        final tempLeftHeel = leftTemps != null && leftTemps.isNotEmpty
            ? leftTemps[0]
            : 0.0;
        final tempLeftBall = leftTemps != null && leftTemps.length > 1
            ? leftTemps[1]
            : 0.0;
        final tempLeftToe = leftTemps != null && leftTemps.length > 2
            ? leftTemps[2]
            : 0.0;
        final tempLeftOppositeHeel = leftTemps != null && leftTemps.length > 3
            ? leftTemps[3]
            : 0.0;
        final tempLeftOppositeBall = leftTemps != null && leftTemps.length > 4
            ? leftTemps[4]
            : 0.0;
        final tempLeftOppositeToe = leftTemps != null && leftTemps.length > 5
            ? leftTemps[5]
            : 0.0;

        final tempRightHeel = rightTemps != null && rightTemps.isNotEmpty
            ? rightTemps[0]
            : 0.0;
        final tempRightBall = rightTemps != null && rightTemps.length > 1
            ? rightTemps[1]
            : 0.0;
        final tempRightToe = rightTemps != null && rightTemps.length > 2
            ? rightTemps[2]
            : 0.0;
        final tempRightOppositeHeel =
            rightTemps != null && rightTemps.length > 3 ? rightTemps[3] : 0.0;
        final tempRightOppositeBall =
            rightTemps != null && rightTemps.length > 4 ? rightTemps[4] : 0.0;
        final tempRightOppositeToe = rightTemps != null && rightTemps.length > 5
            ? rightTemps[5]
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "REAL-TIME PRESSURE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          "Active Foot Health Analysis",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          provider.lastSyncTime != null
                              ? "LIVE (Sync: ${provider.lastSyncTime!.hour.toString().padLeft(2, '0')}:${provider.lastSyncTime!.minute.toString().padLeft(2, '0')})"
                              : "LIVE",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FootPressureWidget(
                pressureLeftHeel: pressureLeftHeel,
                pressureLeftToe: pressureLeftToe,
                pressureLeftBall: pressureLeftBall,
                pressureLeftOppositeHeel: pressureLeftOppositeHeel,
                pressureLeftOppositeToe: pressureLeftOppositeToe,
                pressureLeftOppositeBall: pressureLeftOppositeBall,
                pressureRightHeel: pressureRightHeel,
                pressureRightToe: pressureRightToe,
                pressureRightBall: pressureRightBall,
                pressureRightOppositeHeel: pressureRightOppositeHeel,
                pressureRightOppositeToe: pressureRightOppositeToe,
                pressureRightOppositeBall: pressureRightOppositeBall,
                tempLeftHeel: tempLeftHeel,
                tempLeftToe: tempLeftToe,
                tempLeftBall: tempLeftBall,
                tempLeftOppositeHeel: tempLeftOppositeHeel,
                tempLeftOppositeToe: tempLeftOppositeToe,
                tempLeftOppositeBall: tempLeftOppositeBall,
                tempRightHeel: tempRightHeel,
                tempRightToe: tempRightToe,
                tempRightBall: tempRightBall,
                tempRightOppositeHeel: tempRightOppositeHeel,
                tempRightOppositeToe: tempRightOppositeToe,
                tempRightOppositeBall: tempRightOppositeBall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicalInsightCard() {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        // Check for temperature asymmetry or high pressure alerts
        final tempAlert = provider.getTemperatureAsymmetryAlert();
        final pressureAlert = provider.getHighPressureAlert(threshold: 0.75);

        String alertText = "No anomalies detected. Foot Health: Normal";
        Color alertColor = Colors.green;

        if (tempAlert != null) {
          alertText =
              "Inflammation risk in ${tempAlert.side} feet (${tempAlert.zone}). "
              "Difference: ${tempAlert.difference.toStringAsFixed(1)}°C";
          alertColor = Colors.redAccent;
        } else if (pressureAlert != null) {
          alertText =
              "High pressure detected on ${pressureAlert.affectedZones.join(", ")}. "
              "Consider adjusting your stride or checking insole alignment.";
          alertColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: alertColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, color: alertColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Medical Insight",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: alertColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alertText,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
