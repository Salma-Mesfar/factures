import 'package:facture/model/article.dart';

class Facture {
  final int id;
  final String nomClient;
  final String emailClient;
  final DateTime dateFacture;
  final List<Map<String, dynamic>> articles;
  static int _nextId = 1;

  Facture({
    int? id,
    required this.nomClient,
    required this.emailClient,
    required this.dateFacture,
    required this.articles,
  }) : id = id ?? _nextId++ {
    // Update _nextId if the provided id is larger
    if (id != null && id >= _nextId) {
      _nextId = id + 1;
    }
  }

  double montantTotalHT() {
    double somme = 0;
    for (var articleMap in articles) {
      try {
        Article article = Article.fromJson(articleMap['article'] ?? {});
        somme += article.montantTotalHT * (articleMap['quantité'] as int? ?? 1);
      } catch (e) {
        print("Error calculating article total: $e");
      }
    }
    return somme;
  }

  double tva(double totalHT) {
    return totalHT * 20 / 100;
  }

  double totalTTC(double totalHT, double tva) {
    return totalHT + tva;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomClient': nomClient,
      'emailClient': emailClient,
      'dateFacture': dateFacture.toIso8601String(),
      'articles': articles,
    };
  }

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] as int? ?? 0, // Handle null case
      nomClient: json['nomClient'] as String? ?? '',
      emailClient: json['emailClient'] as String? ?? '',
      dateFacture: DateTime.parse(
        json['dateFacture'] as String? ?? DateTime.now().toString(),
      ),
      articles: List<Map<String, dynamic>>.from(
        json['articles'] as List? ?? [],
      ),
    );
  }
}
