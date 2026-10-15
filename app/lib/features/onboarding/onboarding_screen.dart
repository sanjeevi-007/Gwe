import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/state.dart';
import '../home/main_navigation_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _disclaimerAccepted = false;
  bool _isCompleting = false;

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToDisclaimer() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (!_disclaimerAccepted || _isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    await ref.read(onboardingControllerProvider).completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _totalPages - 1)
            TextButton(
              key: const Key('skip_button'),
              onPressed: _skipToDisclaimer,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppTheme.darkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1Welcome(context),
                  _buildPage2HowItWorks(context),
                  _buildPage3Privacy(context),
                  _buildPage4Disclaimer(context),
                ],
              ),
            ),
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1Welcome(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.darkPrimary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.hub_rounded,
              size: 48,
              color: AppTheme.darkPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to GWEN',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkOnSurface,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your standalone offline-first pulse, motion, and GPS monitoring system.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppTheme.darkOnSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.offline_pin_rounded,
                  color: Color(0xFF00E676),
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '100% Offline. Your data never leaves your device.',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No cloud, no accounts, no login, and no internet connection required. Everything operates directly between your Puck hardware and phone.',
                        style: TextStyle(
                          color: AppTheme.darkOnSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureBullet(
            icon: Icons.favorite_rounded,
            color: const Color(0xFFFF5252),
            title: 'Continuous Vital Signs',
            subtitle: 'Honest heart rate tracking with quality and contact states.',
          ),
          _buildFeatureBullet(
            icon: Icons.directions_run_rounded,
            color: const Color(0xFF00E676),
            title: 'Motion & On-Device AI',
            subtitle: '6-axis IMU tracking with local machine learning on the Puck.',
          ),
          _buildFeatureBullet(
            icon: Icons.place_rounded,
            color: const Color(0xFF00B0FF),
            title: 'Private GPS Telemetry',
            subtitle: 'Offline satellite triangulation with strict local logging.',
          ),
        ],
      ),
    );
  }

  Widget _buildPage2HowItWorks(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.memory_rounded,
              size: 40,
              color: Color(0xFFFFB74D),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How GWEN Works',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkOnSurface,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'The Puck (ESP32) collects heart rate (MAX30102), movement (MPU6050), and location (NEO-6M). On-device AI classifies motion directly on the hardware.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.darkOnSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildHardwareCard(
            sensorName: 'MAX30102',
            role: 'Optical Heart Rate & Pulse',
            description:
                'Samples red and infrared light absorption to detect blood volume changes. Detects signal quality, honest finger decoupling, and sensor state.',
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFFFF5252),
          ),
          const SizedBox(height: 12),
          _buildHardwareCard(
            sensorName: 'MPU6050 + ESP32 AI',
            role: '6-Axis IMU & Motion Classification',
            description:
                'Measures 3-axis acceleration and angular rate at 50 Hz. An on-device classifier evaluates movement patterns directly on the microcontroller.',
            icon: Icons.psychology_rounded,
            color: const Color(0xFF00E676),
          ),
          const SizedBox(height: 12),
          _buildHardwareCard(
            sensorName: 'NEO-6M GPS',
            role: 'Satellite Location Receiver',
            description:
                'Tracks GPS satellites, orbital ephemeris, and HDOP accuracy. Emits 6 distinct states from searching to full 3D lock.',
            icon: Icons.satellite_alt_rounded,
            color: const Color(0xFF00B0FF),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Privacy(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Privacy & Data Ownership',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkOnSurface,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'You are the sole custodian of your telemetry data.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkOnSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPrivacyItem(
            icon: Icons.storage_rounded,
            title: 'Local Drift SQLite Database',
            description:
                'All telemetry readings, sequence metrics, and device logs are stored locally on your device in private SQLite tables. No external cloud databases exist.',
          ),
          const SizedBox(height: 14),
          _buildPrivacyItem(
            icon: Icons.location_off_rounded,
            title: 'GPS Coordinates Stay Local',
            description:
                'GPS coordinates are never uploaded to any remote server or third-party service. Coordinates stay on the Puck and phone unless you manually export them.',
          ),
          const SizedBox(height: 14),
          _buildPrivacyItem(
            icon: Icons.file_upload_outlined,
            title: 'Full Export & Purge Control',
            description:
                'Export your data anytime in open CSV or JSON formats via the native system share sheet, or purge all local history with a single tap in Settings.',
          ),
        ],
      ),
    );
  }

  Widget _buildPage4Disclaimer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB74D).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 44,
                color: Color(0xFFFFB74D),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Important Health & Safety Notice',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFFFB74D),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Mandatory Non-Medical Disclaimer & Terms',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDisclaimerBullet(
                  'NOT a Medical Device',
                  'GWEN is designed for general fitness monitoring and recreational activity observation only. It is NOT certified as a medical device.',
                ),
                const Divider(height: 18),
                _buildDisclaimerBullet(
                  'No Medical Diagnosis or Treatment',
                  'GWEN provides no diagnostic capabilities, clinical status classification, or medical recommendations. Never use GWEN for medical decisions.',
                ),
                const Divider(height: 18),
                _buildDisclaimerBullet(
                  'No Fall Detection or Emergency SOS',
                  'GWEN does NOT provide fall detection, emergency alerts, or automatic dispatch. Do not rely on GWEN for personal safety or life-critical scenarios.',
                ),
                const Divider(height: 18),
                _buildDisclaimerBullet(
                  'Seek Professional Medical Guidance',
                  'Always consult a qualified healthcare provider for any health concerns or symptoms. Do not disregard medical advice based on sensor telemetry.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            key: const Key('disclaimer_checkbox_tile'),
            onTap: () {
              setState(() {
                _disclaimerAccepted = !_disclaimerAccepted;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _disclaimerAccepted
                    ? const Color(0xFF00E676).withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _disclaimerAccepted
                      ? const Color(0xFF00E676).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    key: const Key('disclaimer_checkbox'),
                    value: _disclaimerAccepted,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (val) {
                      setState(() {
                        _disclaimerAccepted = val ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I understand and agree to the health & safety terms.',
                      style: TextStyle(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHardwareCard({
    required String sensorName,
    required String role,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sensorName,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.darkPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBullet(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.block_rounded,
          color: Color(0xFFFFB74D),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.darkOnSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (_currentPage > 0)
            OutlinedButton(
              key: const Key('back_button'),
              onPressed: _prevPage,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.darkOnSurface.withValues(alpha: 0.8),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 80),

          // Page indicators
          Row(
            children: List.generate(_totalPages, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: isSelected ? 22.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.darkPrimary
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),

          // Next or Get Started button
          if (!isLastPage)
            ElevatedButton(
              key: const Key('next_button'),
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                children: [
                  Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            )
          else
            ElevatedButton(
              key: const Key('get_started_button'),
              onPressed: _disclaimerAccepted ? _completeOnboarding : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Get Started',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
        ],
      ),
    );
  }
}
