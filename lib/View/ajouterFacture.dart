import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'listArticles.dart';
import '../model/article.dart';
import '../model/facture.dart';
import '../Controller/data_handler.dart';

class AjouterFacture extends StatefulWidget {
  const AjouterFacture({super.key});

  @override
  State<AjouterFacture> createState() => _AjouterFactureState();
}

class _AjouterFactureState extends State<AjouterFacture> {
  final TextEditingController _nomClient = TextEditingController();
  final TextEditingController _emailClient = TextEditingController();
  DateTime dateFacture = DateTime.now();
  Map<int, int> qttParArticle = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nomClient.dispose();
    _emailClient.dispose();
    super.dispose();
  }

  Future<void> _ajouterFacture() async {
    if (_nomClient.text.isEmpty || _emailClient.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs client"),
        ),
      );
      return;
    }

    if (qttParArticle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter au moins un article")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nouvelleFacture = Facture(
        nomClient: _nomClient.text,
        emailClient: _emailClient.text,
        dateFacture: dateFacture,
        articles:
            qttParArticle.entries.map((entry) {
              final article = ListArticlesState.articles[entry.key];
              return {
                'article':
                    article?.toJson() ??
                    Article(
                      id: 0,
                      description: 'Unknown',
                      quantite: 0,
                      prixUnitaireHT: 0,
                    ).toJson(),
                'quantité': entry.value,
              };
            }).toList(),
      );

      // Mettre à jour les stocks
      setState(() {
        qttParArticle.forEach((index, quantite) {
          ListArticlesState.articles[index].quantite -= quantite;
        });
      });

      // Sauvegarder les deux
      await DataHandler.saveArticles(ListArticlesState.articles);
      await DataHandler.saveFacture(nouvelleFacture);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facture #${nouvelleFacture.id} ajoutée")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculerTotal() {
    double totalHT = 0;
    qttParArticle.forEach((index, quantite) {
      final article = ListArticlesState.articles[index];
      totalHT += article.prixUnitaireHT * quantite;
    });
    return totalHT;
  }

  @override
  Widget build(BuildContext context) {
    final totalHT = _calculerTotal();
    final tva = totalHT * 0.2;
    final totalTTC = totalHT + tva;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        title: const Text("Nouvelle facture"),
      ),
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 22.0,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomClient,
                        decoration: const InputDecoration(
                          labelText: "Nom du client",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailClient,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email du client",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(dateFacture),
                            style: const TextStyle(fontSize: 16),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final dateSelectionnee = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDate: DateTime.now(),
                              );
                              if (dateSelectionnee != null) {
                                setState(() => dateFacture = dateSelectionnee);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFF2D9CDB),
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                            ),
                            child: const Text("Choisir date"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Articles disponibles",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ListArticlesState.articles.length,
                        itemBuilder: (context, index) {
                          final article = ListArticlesState.articles[index];
                          final quantite = qttParArticle[index] ?? 0;

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        article.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "${article.prixUnitaireHT} DH",
                                        style: const TextStyle(
                                          color: Color(0xFF2D9CDB),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Stock: ${article.quantite}"),
                                  Text("Quantité: $quantite"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (quantite > 0) {
                                            setState(() {
                                              qttParArticle[index] =
                                                  quantite - 1;
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          if (quantite < article.quantite) {
                                            setState(() {
                                              qttParArticle[index] =
                                                  quantite + 1;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Quantité indisponible en stock",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total HT:"),
                                  Text(
                                    "${totalHT.toStringAsFixed(2)} DH",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("TVA (20%):"),
                                  Text("${tva.toStringAsFixed(2)} DH"),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total TTC:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${totalTTC.toStringAsFixed(2)} DH",
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
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _ajouterFacture,
                          child: const Text(
                            "AJOUTER LA FACTURE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}
