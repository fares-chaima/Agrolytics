class EvaluationScreen extends StatefulWidget {
  @override
  _EvaluationScreenState createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  bool _loading = false;
  Map<String, dynamic>? _indicators;
  Map<String, String>? _explanations;

  Future<void> fetchEvaluation() async {
    setState(() {
      _loading = true;
      _indicators = null;
      _explanations = null;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.9:8000/agriculture/ev/'));

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la récupération")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget buildIndicator(String title, double value, String explanation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title (${value.toStringAsFixed(1)}%)", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
            minHeight: 10,
          ),
          SizedBox(height: 4),
          Text(explanation, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: Text("Field Evaluation"),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : _indicators != null
              ? SingleChildScrollView(
                  child: Column(
                    children: _indicators!.entries.map((entry) {
                      final key = entry.key;
                      final value = (entry.value as num).toDouble();
                      final explanation = _explanations?[key] ?? "";
                      return buildIndicator(key, value, explanation);
                    }).toList(),
                  ),
                )
              : Center(
                  child: ElevatedButton.icon(
                    onPressed: fetchEvaluation,
                    icon: Icon(Icons.assessment),
                    label: Text("Start Evaluation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ),
    );
  }
}
