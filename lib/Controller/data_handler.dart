import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/article.dart';
import '../model/facture.dart';

class DataHandler {
  // Get the data directory safely using path_provider
  static Future<String> get _dataDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Files JSON
  static Future<File> get _articlesFile async {
    final dir = await _dataDir;
    return File('$dir/articles.json');
  }

  static Future<File> get _facturesFile async {
    final dir = await _dataDir;
    return File('$dir/factures.json');
  }

  // Initialization (Create files if they don't exist)
  static Future<void> init() async {
    final articlesFile = await _articlesFile;
    if (!await articlesFile.exists()) {
      await articlesFile.writeAsString('[]');
    }

    final facturesFile = await _facturesFile;
    if (!await facturesFile.exists()) {
      await facturesFile.writeAsString('[]');
    }
  }

  // Methods for articles
  static Future<List<Article>> loadArticles() async {
    try {
      final file = await _articlesFile;
      final contents = await file.readAsString();
      return (json.decode(contents) as List)
          .map((json) => Article.fromJson(json))
          .toList();
    } catch (e) {
      print("Erreur chargement articles: $e");
      return [];
    }
  }

  static Future<void> saveArticles(List<Article> articles) async {
    final file = await _articlesFile;
    await file.writeAsString(
      json.encode(articles.map((a) => a.toJson()).toList()),
    );
  }

  // Methods for factures
  static Future<List<Facture>> loadFactures() async {
    try {
      final file = await _facturesFile;
      final contents = await file.readAsString();
      return (json.decode(contents) as List)
          .map((json) => Facture.fromJson(json))
          .toList();
    } catch (e) {
      print("Erreur chargement factures: $e");
      return [];
    }
  }

  static Future<void> saveFacture(Facture facture) async {
    final file = await _facturesFile;
    final factures = await loadFactures();

    // Ensure the facture has a valid ID
    if (facture.id <= 0) {
      facture = Facture(
        id: factures.isEmpty ? 1 : factures.last.id + 1,
        nomClient: facture.nomClient,
        emailClient: facture.emailClient,
        dateFacture: facture.dateFacture,
        articles: facture.articles,
      );
    }

    factures.add(facture);
    await file.writeAsString(
      json.encode(factures.map((f) => f.toJson()).toList()),
    );
  }
}
