import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  // ---------------------------------------------------------------------------
  // Design tokens (exact values from the Figma export)
  // ---------------------------------------------------------------------------
  static const Color cardBorder = Color(0x54092A99);
  static const Color tileBorder = Color(0x993C3C43);
  static const Color secondaryText = Color(0xFF3C3C43);
  static const Color farmTitle = Color(0xFF0E30B1);
  static const Color navActive = Color(0xFF3B82F6);

  static const Color dangerColor = Color(0xFFC00000);
  static const Color cautionColor = Color(0xFFDA9100);
  static const Color safeColor = Color(0xFF15B900);

  static const Color cTurbidity = Color(0xFF2A821A);
  static const Color cGas = Color(0xFF007BFF);
  static const Color cPressure = Color(0xFFFF6A00);
  static const Color cWaterTemp = Color(0xFF8300FF);
  static const Color cHumidity = Color(0xFFB90297);
  static const Color cTemperature = Color(0xFF9B4A21);

  // Sample data (matches Figma). Replace with your Firebase data later.
  final List<Farm> _farms = [
    Farm(
      name: 'Farm A',
      status: FarmStatus.danger,
      message: 'Critical water quality detected. Immediate action required to prevent fish or plant stress.',
      metrics: [
        FarmMetric('Turbidity', '14', 'NTU', cTurbidity),
        FarmMetric('Gas', '1400', 'µg/m³', cGas),
        FarmMetric('Pressure', '985', 'hPa', cPressure),
        FarmMetric('Water Temp', '36', '°C', cWaterTemp),
        FarmMetric('Humidity', '95', '%', cHumidity),
        FarmMetric('Temperature', '38', '°C', cTemperature),
      ],
    ),
    Farm(
      name: 'Farm B',
      status: FarmStatus.caution,
      message: 'Turbidity and water temperature are above the optimal range.',
      metrics: [
        FarmMetric('Turbidity', '8', 'NTU', cTurbidity),
        FarmMetric('Gas', '780', 'µg/m³', cGas),
        FarmMetric('Pressure', '997', 'hPa', cPressure),
        FarmMetric('Water Temp', '32', '°C', cWaterTemp),
        FarmMetric('Humidity', '85', '%', cHumidity),
        FarmMetric('Temperature', '34', '°C', cTemperature),
      ],
    ),
    Farm(
      name: 'Farm C',
      status: FarmStatus.safe,
      message: 'All water quality and environmental conditions are stable.',
      metrics: [
        FarmMetric('Turbidity', '3', 'NTU', cTurbidity),
        FarmMetric('Gas', '320', 'µg/m³', cGas),
        FarmMetric('Pressure', '1013', 'hPa', cPressure),
        FarmMetric('Water Temp', '27', '°C', cWaterTemp),
        FarmMetric('Humidity', '72', '%', cHumidity),
        FarmMetric('Temperature', '29', '°C', cTemperature),
      ],
    ),
  ];

  int _countOf(FarmStatus s) => _farms.where((f) => f.status == s).length;

  String get _firstName {
    final display = widget.user.displayName;
    if (display != null && display.trim().isNotEmpty) {
      return display.trim().split(' ').first;
    }
    final email = widget.user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 6, bottom: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $_firstName! 👋🏻',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'Last updated 2 minutes ago',
                                style: TextStyle(color: secondaryText, fontSize: 12),
                              ),
                              const SizedBox(height: 29),
                              _sectionTitle('Overview'),
                              const SizedBox(height: 22),
                              _buildOverviewGrid(),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: _sectionTitle('Farms Overview'),
                        ),
                        const SizedBox(height: 18),
                        for (final farm in _farms) _buildFarmCard(farm),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      );

  // ---------------------------------------------------------------------------
  // Top bar: profile | logo | bell
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Account',
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.person_outline_rounded, size: 40, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') _authService.signOut();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
          Expanded(
            child: Center(
              // Export your logo from Figma as assets/images/logo.png
              child: Image.asset(
                'assets/images/logo.png',
                height: 53,
                errorBuilder: (_, __, ___) => const Text(
                  'AQUACARE+',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2B3FE0)),
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                tooltip: 'Notifications',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_none_rounded, size: 40, color: Colors.black),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFE8342B), shape: BoxShape.circle),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Overview 2x2
  // ---------------------------------------------------------------------------
  Widget _buildOverviewGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard('TOTAL FARMS', _farms.length, Colors.black,
                  'assets/images/fish_tank.png', Icons.set_meal_outlined),
            ),
            const SizedBox(width: 19),
            Expanded(
              child: _summaryCard('DANGER', _countOf(FarmStatus.danger), dangerColor,
                  'assets/images/danger.png', Icons.warning_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _summaryCard('CAUTION', _countOf(FarmStatus.caution), cautionColor,
                  'assets/images/caution.png', Icons.error_rounded),
            ),
            const SizedBox(width: 19),
            Expanded(
              child: _summaryCard('SAFE', _countOf(FarmStatus.safe), safeColor,
                  'assets/images/safe.png', Icons.verified_user_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String label, int count, Color color, String asset, IconData fallback) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Row(
        children: [
          _assetOrIcon(asset, fallback, color, 48),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '$count',
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetOrIcon(String asset, IconData fallback, Color color, double size) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(fallback, size: size, color: color),
    );
  }

  // ---------------------------------------------------------------------------
  // Farm card
  // ---------------------------------------------------------------------------
  Widget _buildFarmCard(Farm farm) {
    final rows = <Widget>[];
    for (var i = 0; i < farm.metrics.length; i += 3) {
      final slice = farm.metrics.skip(i).take(3).toList();
      rows.add(Row(
        children: [
          for (var j = 0; j < slice.length; j++) ...[
            Expanded(child: _metricTile(slice[j])),
            if (j != slice.length - 1) const SizedBox(width: 7),
          ],
        ],
      ));
      if (i + 3 < farm.metrics.length) rows.add(const SizedBox(height: 18));
    }

    return Container(
      margin: const EdgeInsets.only(left: 18, right: 18, bottom: 28),
      padding: const EdgeInsets.fromLTRB(19, 21, 19, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  farm.name,
                  style: const TextStyle(color: farmTitle, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _statusBadge(farm.status),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...rows,
          const SizedBox(height: 21),
          _alertBanner(farm),
        ],
      ),
    );
  }

  Widget _statusBadge(FarmStatus status) {
    late final Color bg, border;
    late final String text;
    switch (status) {
      case FarmStatus.danger:
        bg = const Color(0xFFFF0000);
        border = const Color(0xFFC00000);
        text = 'Danger';
        break;
      case FarmStatus.caution:
        bg = const Color(0xFFFFBF00);
        border = const Color(0xFFCB9900);
        text = 'Caution';
        break;
      case FarmStatus.safe:
        bg = const Color(0xFF15B900);
        border = const Color(0xFF127900);
        text = 'Safe';
        break;
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _metricTile(FarmMetric m) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tileBorder, width: 1),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              m.label,
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              m.value,
              style: TextStyle(color: m.color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              m.unit,
              style: TextStyle(color: m.color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertBanner(Farm farm) {
    late final Color bg;
    late final String icon;
    late final IconData fallback;
    late final Color iconColor;
    switch (farm.status) {
      case FarmStatus.danger:
        bg = const Color(0x17FF0101);
        icon = 'assets/images/danger.png';
        fallback = Icons.warning_rounded;
        iconColor = dangerColor;
        break;
      case FarmStatus.caution:
        bg = const Color(0x26FFBF00);
        icon = 'assets/images/caution.png';
        fallback = Icons.error_rounded;
        iconColor = cautionColor;
        break;
      case FarmStatus.safe:
        bg = const Color(0x1F15B900);
        icon = 'assets/images/safe.png';
        fallback = Icons.verified_user_rounded;
        iconColor = safeColor;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        // TODO: open farm details screen
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: tileBorder, width: 1),
        ),
        child: Row(
          children: [
            _assetOrIcon(icon, fallback, iconColor, 28),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                farm.message,
                style: const TextStyle(color: Colors.black, fontSize: 11),
              ),
            ),
            const SizedBox(width: 9),
            const Icon(Icons.chevron_right_rounded, size: 30, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom navigation
  // ---------------------------------------------------------------------------
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0xFFE5E5EA), blurRadius: 3, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, null),
              _navItem(1, Icons.set_meal_outlined, Icons.set_meal_rounded, 'assets/images/fish_tank.png'),
              _navItem(2, Icons.search_rounded, Icons.search_rounded, null),
              _navItem(3, Icons.settings_outlined, Icons.settings_rounded, null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String? asset) {
    final selected = _currentIndex == index;
    final color = selected ? navActive : Colors.black;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
          // TODO: navigate to the matching screen
        },
        child: Center(
          child: asset != null
              ? Image.asset(
                  asset,
                  width: 52,
                  height: 52,
                  errorBuilder: (_, __, ___) => Icon(selected ? activeIcon : icon, size: 40, color: color),
                )
              : Icon(selected ? activeIcon : icon, size: 40, color: color),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------
enum FarmStatus { danger, caution, safe }

class FarmMetric {
  final String label;
  final String value;
  final String unit;
  final Color color;

  FarmMetric(this.label, this.value, this.unit, this.color);
}

class Farm {
  final String name;
  final FarmStatus status;
  final String message;
  final List<FarmMetric> metrics;

  Farm({
    required this.name,
    required this.status,
    required this.message,
    required this.metrics,
  });
}