class Article {
  final int id;
  final String description;
  int quantite;
  final double prixUnitaireHT;

  Article({
    required this.id,
    required this.description,
    required this.quantite,
    required this.prixUnitaireHT,
  });
  double get montantTotalHT => quantite * prixUnitaireHT;
  static double montantTotalHT2(double prix, int qtt) {
    return prix * qtt;
  }

  // Méthode pour convertir un Article en Map (pour JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantite': quantite,
      'prixUnitaireHT': prixUnitaireHT,
    };
  }

  // Factory method pour créer un Article à partir d'une Map (depuis JSON)
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int? ?? 0, // Provide default value if null
      description: json['description'] as String? ?? '',
      quantite: (json['quantite'] as int? ?? 0).clamp(
        0,
        999999,
      ), // Ensure positive quantity
      prixUnitaireHT:
          (json['prixUnitaireHT'] as num?)?.toDouble() ??
          0.0, // Handle num or double
    );
  }
}
