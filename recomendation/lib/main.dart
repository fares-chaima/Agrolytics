import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

// 🟢 Entry point
void main() => runApp(MyApp());

// 🟢 Main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agriculture Advisor',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color(0xFFF0FAF2),
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFF015212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF015212),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF015212),
          background: Colors.white,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // 👈 page de démarrage
    );
  }
}

// 🟢 SplashScreen animé
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Courbe d'animation pour agrandir
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Courbe d'animation pour rotation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.1416).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Naviguer après 3 secondes
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'assets/agroly.png',
                  width: 250, // ✅ grand logo
                  height: 250,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// 🟢 MainScreen avec navigation
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdviceScreen(),
    CropRecommendationScreen(),
    EvaluationScreen(),
    ChartEvaluationScreen(),
    SoilStatDashboardScreen(),
    SensorDashboardScreen(),
    WeatherScreen(),
    MarketTrendsScreen(),
    AgriculturalIncomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates), label: 'Advice'),
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: 'Crops'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Evaluation'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Charts'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensors'),
          BottomNavigationBarItem(icon: Icon(Icons.biotech), label: 'Soil Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'Météo'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marché'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Revenu'),
        ],
      ),
    );
  }
}

class AdviceScreen extends StatefulWidget {
  @override
  _AdviceScreenState createState() => _AdviceScreenState();
}
class _AdviceScreenState extends State<AdviceScreen> {
  List<dynamic> _adviceList = [];
  bool _loading = true;

  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF0FAF2); // ✅ Vert très pâle
  final Color mainColor = Color(0xFF015212); // ✅ Vert foncé pour les icônes

  @override
  void initState() {
    super.initState();
    fetchAdvice();
  }

  Future<void> fetchAdvice() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/agriculture/advice/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _adviceList = data['conseils'];
          _loading = false;
        });
      } else {
        throw Exception('Erreur de récupération');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
    }
  }

  Widget buildAdviceCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white, // ✅ fond blanc
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mainColor, width: 2), // ✅ bordure verte
                  ),
                  child: Center(
                    child: Text(
                      item['icon'] ?? "🌱",
                      style: TextStyle(fontSize: 24, color: mainColor), // ✅ icône verte
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title_en'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: mainColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        item['subtitle_en'] ?? 'No advice available.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: mainColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Field Advice'),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 3,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading advice...',
                    style: TextStyle(color: mainColor),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: mainColor,
              backgroundColor: backgroundColor,
              onRefresh: fetchAdvice,
              child: ListView(
                children: _adviceList.map((item) => buildAdviceCard(item)).toList(),
              ),
            ),
    );
  }
}



class CropRecommendationScreen extends StatefulWidget {
  @override
  _CropRecommendationScreenState createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  List<dynamic> _crops = [];
  bool _loading = true;

  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF0FAF2); // Vert très pâle
  final Color mainColor = Color(0xFF015212); // Vert foncé

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/get_agriculture_recommendations/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _crops = data['recommended_crops'];
          _loading = false;
        });
      } else {
        throw Exception('Failed to load crops');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error: $e");
    }
  }

  Widget buildCropCard(Map<String, dynamic> crop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                crop['name'] ?? "Unknown Crop",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                crop['detail'] ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: (crop['badges'] as List<dynamic>? ?? [])
                    .map((badge) => Chip(
                          label: Text(badge['text']),
                          backgroundColor: badge['type'] == 'optimal'
                              ? mainColor.withOpacity(0.15)
                              : Colors.grey[300],
                          labelStyle: TextStyle(
                            color: mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Crop Recommendations'),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 3,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            )
          : RefreshIndicator(
              color: mainColor,
              backgroundColor: backgroundColor,
              onRefresh: fetchRecommendations,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '🌾 Top 4 recommended crops for your field:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: mainColor,
                      ),
                    ),
                  ),
                  ..._crops.map((crop) => buildCropCard(crop)).toList(),
                ],
              ),
            ),
    );
  }
}


class EvaluationScreen extends StatefulWidget {
  @override
  _EvaluationScreenState createState() => _EvaluationScreenState();
}



class _EvaluationScreenState extends State<EvaluationScreen> {
  bool _loading = false;
  Map<String, dynamic>? _indicators;
  Map<String, String>? _explanations;

  final Color backgroundColor = Colors.white;
  final Color mainColor = Color(0xFF015212);
  final Color cardColor = Color(0xFFF0FAF2);

  @override
  void initState() {
    super.initState();
    fetchEvaluation(); // ⬅️ Démarrage automatique
  }

  Future<void> fetchEvaluation() async {
    setState(() {
      _loading = true;
      _indicators = null;
      _explanations = null;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/agriculture/ev/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['evaluation'] as String;

        final jsonPart = RegExp(r'{[^}]+}').stringMatch(content);
        final explanationPart = content.replaceAll(jsonPart ?? '', '').trim();

        if (jsonPart != null) {
          final Map<String, dynamic> indicators = json.decode(jsonPart.replaceAll("'", '"'));

          final Map<String, String> explanations = {};
          final lines = explanationPart.split('\n');
          for (var line in lines) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              final key = parts[0].trim();
              final value = parts.sublist(1).join(':').trim();
              explanations[key] = value;
            }
          }

          setState(() {
            _indicators = indicators;
            _explanations = explanations;
          });
        }
      } else {
        throw Exception('Erreur serveur');
      }
    } catch (e) {
      print('Erreur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget buildIndicator(String title, double value, String explanation) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title (${value.toStringAsFixed(1)}%)",
            style: TextStyle(fontWeight: FontWeight.bold, color: mainColor),
          ),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            color: mainColor,
            backgroundColor: mainColor.withOpacity(0.2),
            minHeight: 10,
          ),
          SizedBox(height: 6),
          Text(
            explanation,
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Field Evaluation"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _indicators != null
              ? RefreshIndicator(
                  color: mainColor,
                  backgroundColor: backgroundColor,
                  onRefresh: fetchEvaluation,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: _indicators!.entries.map((entry) {
                          final key = entry.key;
                          final value = (entry.value as num).toDouble();
                          final explanation = _explanations?[key] ?? "";
                          return buildIndicator(key, value, explanation);
                        }).toList(),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    "Aucune donnée disponible",
                    style: TextStyle(color: mainColor),
                  ),
                ),
    );
  }
}



class ChartEvaluationScreen extends StatefulWidget {
  @override
  _ChartEvaluationScreenState createState() => _ChartEvaluationScreenState();
}
class _ChartEvaluationScreenState extends State<ChartEvaluationScreen> {
  bool _loading = false;
  Map<String, dynamic>? _indicators;

  final Color mainColor = const Color(0xFF015212);
  final Color backgroundColor = Colors.white;
  final Color cardColor = const Color(0xFFF0FAF2);

  final List<String> keys = [
    'photosynthetic_activity',
    'soil_moisture_level',
    'crop_yield_estimation',
    'nutrient_deficiency_risk',
    'chlorophyll_content',
    'evapotranspiration_rate',
  ];

  @override
  void initState() {
    super.initState();
    fetchEvaluation(); // ⬅️ Évaluation automatique au démarrage
  }

  Future<void> fetchEvaluation() async {
    setState(() {
      _loading = true;
      _indicators = null;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/agriculture/evaluation/'));
      if (response.statusCode == 200) {
        setState(() {
          _indicators = json.decode(response.body);
        });
      } else {
        throw Exception("Erreur serveur");
      }
    } catch (e) {
      print("Erreur : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget buildBarChart() {
    if (_indicators == null) return SizedBox();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= keys.length) return SizedBox();
                  return SideTitleWidget(
                    space: 8,
                    meta: meta,
                    child: Text(
                      keys[index].replaceAll('_', '\n'),
                      style: TextStyle(fontSize: 10, color: mainColor),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: keys.asMap().entries.map((entry) {
            final index = entry.key;
            final key = entry.value;
            final rawValue = _indicators?[key];
            final value = rawValue is num ? rawValue.toDouble() : double.tryParse(rawValue.toString()) ?? 0.0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 18,
                  color: mainColor,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: mainColor.withOpacity(0.2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildIndicator(String title, double value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ${value.toStringAsFixed(1)}%",
            style: TextStyle(fontWeight: FontWeight.bold, color: mainColor),
          ),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: mainColor.withOpacity(0.2),
            color: mainColor,
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Agriculture Evaluation"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _indicators == null
              ? Center(child: Text("Aucune donnée trouvée", style: TextStyle(color: mainColor)))
              : RefreshIndicator(
                  color: mainColor,
                  onRefresh: fetchEvaluation,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        SizedBox(height: 320, child: buildBarChart()),
                        Divider(height: 32, color: Colors.grey[300]),
                        ...keys.map((key) {
                          final raw = _indicators?[key];
                          final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
                          return buildIndicator(key, value);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}





class SensorDashboardScreen extends StatefulWidget {
  @override
  _SensorDashboardScreenState createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  List<dynamic> sensors = [];

  final Color mainColor = const Color(0xFF015212);
  final Color cardColor = const Color(0xFFF0FAF2);
  final Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    fetchSensors();
  }

  Future<void> fetchSensors() async {
    final response = await http.get(Uri.parse("http://192.168.1.5:8000/api/iot-sensors/"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        sensors = data['sensors'];
      });
    } else {
      print("Erreur serveur");
    }
  }

  double extractPercent(String value) {
    final percent = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    return percent != null ? (percent / 100).clamp(0.0, 1.0) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Capteurs IoT"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: sensors.isEmpty
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                final value = sensor['value'];
                final percent = extractPercent(value);
                final isOptimal = sensor['status'] == "optimal";

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 8.0,
                          percent: percent,
                          center: Text("${(percent * 100).toInt()}%",
                              style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                          progressColor: isOptimal ? mainColor : Colors.red,
                          backgroundColor: Colors.grey[300]!,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${sensor['icon']} ${sensor['label']}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor)),
                              SizedBox(height: 4),
                              Text(sensor['location'],
                                  style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                              SizedBox(height: 4),
                              Text("Status: ${sensor['status']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isOptimal ? mainColor : Colors.red,
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


class SoilStatDashboardScreen extends StatefulWidget {
  @override
  _SoilStatDashboardScreenState createState() => _SoilStatDashboardScreenState();
}

class _SoilStatDashboardScreenState extends State<SoilStatDashboardScreen> {
  List<dynamic> stats = [];

  final Color mainColor = const Color(0xFF015212);
  final Color cardColor = const Color(0xFFF0FAF2);
  final Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    fetchSoilStats();
  }

  Future<void> fetchSoilStats() async {
    final response = await http.get(Uri.parse("http://192.168.1.5:8000/api/iot-sensor/"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        stats = data['stats'];
      });
    } else {
      print("Erreur de chargement des stats");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Soil Stats"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: stats.isEmpty
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : ListView.builder(
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                final value = stat['value'] is double
                    ? stat['value']
                    : double.tryParse(stat['value'].toString()) ?? 0.0;

                double percent = (value / 100).clamp(0.0, 1.0);

                final progressColor = Color(
                    int.parse(stat['color'].substring(1, 7), radix: 16) + 0xFF000000);

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 8.0,
                          percent: percent,
                          center: Text("${(percent * 100).toInt()}%",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: mainColor)),
                          progressColor: progressColor,
                          backgroundColor: Colors.grey[300]!,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stat['title'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor)),
                              SizedBox(height: 4),
                              Text("Valeur : ${stat['value']}",
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}



class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<dynamic> forecast = [];
  String location = "";
  bool isLoading = true;

  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF0FAF2);
  final Color mainColor = Color(0xFF015212);

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final response = await http.get(Uri.parse("http://192.168.1.5:8000/get_weather_forecast/"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        forecast = data['forecast'];
        location = data['location'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Erreur de récupération météo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('🌤️ Météo - $location'),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: mainColor),
            )
          : ListView.builder(
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                final day = forecast[index];

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.park, color: mainColor, size: 32),
                      title: Text(
                        day['date'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          Text("🌤️ Condition : ${day['condition']}"),
                          Text("🌡️ Moyenne : ${day['avg_temp']}°C"),
                          Text("📈 Max : ${day['max_temp']}°C  |  📉 Min : ${day['min_temp']}°C"),
                          Text("💧 Humidité : ${day['humidity']}%"),
                          Text("☔ Précipitations : ${day['rain']} mm"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}



class MarketTrendsScreen extends StatefulWidget {
  @override
  _MarketTrendsScreenState createState() => _MarketTrendsScreenState();
}

class _MarketTrendsScreenState extends State<MarketTrendsScreen> {
  List<dynamic> marketData = [];
  bool isLoading = true;

  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF0FAF2);
  final Color mainColor = Color(0xFF015212);

  @override
  void initState() {
    super.initState();
    fetchMarketTrends();
  }

  Future<void> fetchMarketTrends() async {
    final response = await http.get(Uri.parse("http://192.168.1.5:8000/api/market-trends/"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        marketData = data['market_data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Erreur de récupération des tendances du marché");
    }
  }

  Icon _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Icon(Icons.trending_up, color: Colors.green, size: 24);
      case 'falling':
        return Icon(Icons.trending_down, color: Colors.red, size: 24);
      default:
        return Icon(Icons.trending_flat, color: Colors.orange, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('📊 Tendances du Marché'),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : ListView.builder(
              itemCount: marketData.length,
              itemBuilder: (context, index) {
                final item = marketData[index];

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _getTrendIcon(item["Forecast"]),
                            SizedBox(width: 10),
                            Text(
                              item["Crop"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text("💰 Prix actuel : ${item["Price"]}", style: TextStyle(fontSize: 15)),
                        Text("📉 Changement : ${item["Change"]}", style: TextStyle(fontSize: 15)),
                        Text("📈 Tendance : ${item["Forecast"]}", style: TextStyle(fontSize: 15)),
                        Text("🔍 Action recommandée : ${item["Action"]}",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}









class AgriculturalIncomeScreen extends StatefulWidget {
  @override
  _AgriculturalIncomeScreenState createState() => _AgriculturalIncomeScreenState();
}

class _AgriculturalIncomeScreenState extends State<AgriculturalIncomeScreen> {
  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, dynamic>> _cultures = [];
  List<dynamic> _results = [];
  bool isLoading = false;
  String climate = "";

  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF0FAF2);
  final Color mainColor = Color(0xFF015212);

  void _addCulture() {
    setState(() {
      _cultures.add({"Produit": "", "Hectares": ""});
    });
  }

  Future<void> _calculateIncome() async {
    setState(() {
      isLoading = true;
    });

    final validCultures = _cultures
        .where((c) => c["Produit"].toString().isNotEmpty && c["Hectares"].toString().isNotEmpty)
        .map((c) => {
              "Produit": c["Produit"],
              "Hectares": double.tryParse(c["Hectares"]) ?? 0.0,
            })
        .toList();

    final url = Uri.parse("http://192.168.1.5:8000/api/agriculture/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "location": _locationController.text,
        "cultures": validCultures,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _results = data["resultats"];
        climate = data["climat"];
      });
    } else {
      print("Erreur : ${response.body}");
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildCultureInput(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Produit",
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => _cultures[index]["Produit"] = value,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Hectares",
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _cultures[index]["Hectares"] = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🌤️ Climat actuel : $climate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: mainColor)),
        SizedBox(height: 10),
        ..._results.map((item) => Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: ListTile(
                title: Text(item["Produit"], style: TextStyle(fontWeight: FontWeight.bold, color: mainColor)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🌾 Rendement : ${item["Rendement (t/ha)"]} t/ha"),
                    Text("📦 Production : ${item["Production (t)"]} t"),
                    Text("💰 Prix : ${item["Prix (DZD/t)"]} DZD/t"),
                    Text("📈 Revenu : ${item["Revenu (DZD)"]} DZD"),
                  ],
                ),
              ),
            ))
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _addCulture,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Ajouter Culture", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _calculateIncome,
            icon: Icon(Icons.calculate, color: Colors.white),
            label: isLoading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text("Calculer Revenu", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("🧮 Calcul Revenu Agricole"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Localisation (ex: Sidi Bel Abbès)",
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),
            ...List.generate(_cultures.length, (i) => _buildCultureInput(i)),
            SizedBox(height: 16),
            _buildButtons(),
            SizedBox(height: 30),
            if (_results.isNotEmpty) _buildResultsTable(),
          ],
        ),
      ),
    );
  }
}
