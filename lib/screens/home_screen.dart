import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  // Color Palette
  static const Color darkNavy = Color(0xFF03045E);
  static const Color primaryOcean = Color(0xFF0077B6);
  static const Color aquaBlue = Color(0xFF00B4D8);
  static const Color softBackground = Color(0xFFF4F9FC);

  // Sensor telemetry data mapping for Aquacare+
  final Map<String, DynamicMetric> _metrics = {
    'dissolved_oxygen': DynamicMetric(
      title: 'Dissolved Oxygen',
      value: '0',
      unit: 'µg/m³',
      lastUpdate: 'Last update 5d ago',
      color: const Color(0xFF2ECC71),
      icon: Icons.science_outlined,
    ),
    'electrical_conductivity': DynamicMetric(
      title: 'Electrical Conductivity',
      value: '399',
      unit: 'µS/cm',
      lastUpdate: 'Last update 5d ago',
      color: const Color(0xFFC0392B),
      icon: Icons.bolt_outlined,
    ),
    'ambient_humidity': DynamicMetric(
      title: 'Ambient Humidity',
      value: '59',
      unit: '%',
      lastUpdate: 'Last update 5d ago',
      color: primaryOcean,
      icon: Icons.water_outlined,
    ),
    'ph_level': DynamicMetric(
      title: 'pH Level',
      value: '4.99',
      unit: 'pH',
      lastUpdate: 'Last update 5d ago',
      color: const Color(0xFF00A896),
      icon: Icons.speed_outlined,
    ),
    'ambient_temp': DynamicMetric(
      title: 'Ambient Temperature',
      value: '23',
      unit: '°C',
      lastUpdate: 'Last update 5d ago',
      color: const Color(0xFF8E44AD),
      icon: Icons.thermostat_outlined,
    ),
    'water_temp': DynamicMetric(
      title: 'Water Temperature',
      value: '16.5',
      unit: '°C',
      lastUpdate: 'Last update 5d ago',
      color: aquaBlue,
      icon: Icons.water_drop_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: Row(
          children: [
            // LOGO PLACEHOLDER IN APPBAR
            // Replace Icon with Image.asset('assets/logo.png', height: 26) when ready
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: aquaBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Aquacare', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '+', style: TextStyle(color: aquaBlue)),
                  TextSpan(
                    text: ' Dashboard',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: 'Export Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildMetricsGrid(crossAxisCount: 2)),
                  const SizedBox(width: 16),
                  Expanded(flex: 6, child: _buildRealtimeChartCard()),
                ],
              )
            : Column(
                children: [
                  _buildMetricsGrid(crossAxisCount: 2),
                  const SizedBox(height: 16),
                  _buildRealtimeChartCard(),
                ],
              ),
      ),
    );
  }

  // 6 Metric Display Cards
  Widget _buildMetricsGrid({required int crossAxisCount}) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _metrics.length,
      itemBuilder: (context, index) {
        final key = _metrics.keys.elementAt(index);
        final item = _metrics[key]!;
        return _buildMetricCard(item);
      },
    );
  }

  Widget _buildMetricCard(DynamicMetric metric) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: primaryOcean.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(metric.icon, color: metric.color, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      metric.lastUpdate,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metric.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: metric.color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                metric.unit,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: metric.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Realtime Chart Widget
  Widget _buildRealtimeChartCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: primaryOcean.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Realtime Data Monitoring',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),
                  Text(
                    'Realtime - last 2 minutes',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _legendItem('Humidity', primaryOcean),
                    const SizedBox(width: 6),
                    _legendItem('Ambient Temp', const Color(0xFFC0392B)),
                    const SizedBox(width: 6),
                    _legendItem('Water pH', const Color(0xFF00A896)),
                    const SizedBox(width: 6),
                    _legendItem('Water Temp', aquaBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (val) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final times = ['19:54:45', '19:55', '19:55:15', '19:55:30', '19:55:45', '19:56'];
                        int index = value.toInt();
                        if (index >= 0 && index < times.length) {
                          return Text(times[index], style: const TextStyle(fontSize: 9, color: Colors.grey));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 59), FlSpot(1, 59), FlSpot(2, 59), FlSpot(3, 59), FlSpot(4, 59), FlSpot(5, 59)],
                    isCurved: true,
                    color: primaryOcean,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 23), FlSpot(1, 23), FlSpot(2, 23), FlSpot(3, 23), FlSpot(4, 23), FlSpot(5, 23)],
                    isCurved: true,
                    color: const Color(0xFFC0392B),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 16.5), FlSpot(1, 16.5), FlSpot(2, 16.5), FlSpot(3, 16.5), FlSpot(4, 16.5), FlSpot(5, 16.5)],
                    isCurved: true,
                    color: aquaBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String name, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(name, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
      ],
    );
  }
}

class DynamicMetric {
  final String title;
  final String value;
  final String unit;
  final String lastUpdate;
  final Color color;
  final IconData icon;

  DynamicMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.lastUpdate,
    required this.color,
    required this.icon,
  });
}