import 'package:flutter/material.dart';
import 'ajouterFacture.dart';
import 'listArticles.dart';
import '../model/facture.dart';
import '../model/article.dart';
import '../Controller/data_handler.dart';
import 'package:intl/intl.dart';

class FacturePage extends StatefulWidget {
  const FacturePage({super.key});

  @override
  State<FacturePage> createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePage> {
  List<Facture> factures = [];
  Facture? selectedFacture;
  bool showPreview = false;

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  Future<void> _loadFactures() async {
    try {
      final loadedFactures = await DataHandler.loadFactures();
      setState(() {
        factures = loadedFactures.where((f) => f.id != null).toList();
      });
    } catch (e) {
      print("Error loading factures: $e");
      setState(() {
        factures = [];
      });
    }
  }

  void _togglePreview(Facture facture) {
    setState(() {
      showPreview = !showPreview;
      selectedFacture = showPreview ? facture : null;
    });
  }

  Widget _buildInvoicePreview(Facture facture) {
    double totalHT = 0;
    final articlesWithQuantities =
        facture.articles.map((articleMap) {
          // Ensure we have a Map<String, dynamic> for the article
          final articleJson =
              articleMap['article'] is Map
                  ? Map<String, dynamic>.from(articleMap['article'] as Map)
                  : <String, dynamic>{};

          final article = Article.fromJson(articleJson);
          final quantite = (articleMap['quantité'] as num?)?.toInt() ?? 0;
          final totalArticle = article.prixUnitaireHT * quantite;
          totalHT += totalArticle;

          return {
            'article': article,
            'quantite': quantite,
            'total': totalArticle,
          };
        }).toList();
    final tva = totalHT * 0.2;
    final totalTTC = totalHT + tva;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la facture
          Center(
            child: Text(
              'FACTURE N°${facture.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D9CDB),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Informations client
          Row(
            children: [
              const Text(
                'Client: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(facture.nomClient),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Email: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(facture.emailClient),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Date: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(DateFormat('dd/MM/yyyy').format(facture.dateFacture)),
            ],
          ),
          const SizedBox(height: 20),

          // Ligne de séparation
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // En-tête du tableau
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Qte',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'PU HT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          // Liste des articles
          ...articlesWithQuantities.map((item) {
            final article = item['article'] as Article;
            final quantite = item['quantite'] as int;
            final total = item['total'] as double;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: Text(article.description)),
                  Expanded(
                    child: Text(
                      quantite.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${article.prixUnitaireHT.toStringAsFixed(2)} DH',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${total.toStringAsFixed(2)} DH',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // Totaux
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total HT:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${totalHT.toStringAsFixed(2)} DH',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TVA (20%):'),
                    Text('${tva.toStringAsFixed(2)} DH'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total TTC:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${totalTTC.toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D9CDB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Page de facture"),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child:
                factures.isEmpty
                    ? const Center(child: Text("Aucune facture disponible"))
                    : ListView.builder(
                      itemCount: factures.length,
                      itemBuilder: (context, index) {
                        final facture = factures[index];
                        if (facture.id == null) return Container();

                        final totalHT = facture.montantTotalHT();
                        final totalTTC = facture.totalTTC(
                          totalHT,
                          facture.tva(totalHT),
                        );

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text("Facture N°${facture.id}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Client: ${facture.nomClient}"),
                                Text(
                                  "Date: ${DateFormat('dd/MM/yyyy').format(facture.dateFacture)}",
                                ),
                                Text(
                                  "Total TTC: ${totalTTC.toStringAsFixed(2)} DH",
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                showPreview && selectedFacture?.id == facture.id
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => _togglePreview(facture),
                            ),
                            onTap: () => _togglePreview(facture),
                          ),
                        );
                      },
                    ),
          ),
          if (showPreview && selectedFacture != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: const Border(
                  top: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: _buildInvoicePreview(selectedFacture!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D9CDB),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjouterFacture()),
          );
          _loadFactures();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_frames_rounded),
            label: "Page des factures",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: "Liste des articles",
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFD8ECFF),
        backgroundColor: Color(0xFF2D9CDB),
        onTap: (int index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListArticles()),
              );
              break;
          }
        },
      ),
    );
  }
}
