import 'package:facture/Controller/data_handler.dart';
import 'package:flutter/material.dart';
import '../model/article.dart';
import 'facturePage.dart';

class ListArticles extends StatefulWidget {
  const ListArticles({super.key});

  @override
  State<ListArticles> createState() => ListArticlesState();
}

class ListArticlesState extends State<ListArticles> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixUnitaireController = TextEditingController();

  static List<Article> articles = [];
  int id = 1;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final loadedArticles = await DataHandler.loadArticles();
    setState(() {
      articles = loadedArticles;
      if (articles.isNotEmpty) {
        id = articles.last.id + 1;
      }
    });
  }

  Future<void> addArticle() async {
    final nvArticle = Article(
      id: id++,
      description: _descriptionController.text,
      quantite: int.tryParse(_quantiteController.text) ?? 0,
      prixUnitaireHT: double.tryParse(_prixUnitaireController.text) ?? 0.0,
    );

    setState(() {
      articles.add(nvArticle);
    });

    await DataHandler.saveArticles(articles);

    _descriptionController.clear();
    _prixUnitaireController.clear();
    _quantiteController.clear();
  }

  Future<void> deleteArticle(int index) async {
    setState(() {
      articles.removeAt(index);
    });
    await DataHandler.saveArticles(articles);
  }

  @override
  dispose() {
    _descriptionController.dispose();
    _quantiteController.dispose();
    _prixUnitaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Liste des articles"),
      ),
      backgroundColor: Colors.white,
      body:
          articles.isEmpty
              ? const Center(child: Text("Aucun article disponible"))
              : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(12.0),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(articles[index].description),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Prix unitaire: ${articles[index].prixUnitaireHT.toString()} DH",
                            ),
                            Text(
                              "Quantité: ${articles[index].quantite.toString()}",
                            ),
                          ],
                        ),
                        leading: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text("Confirmer la suppression"),
                                    content: Text(
                                      "Voulez-vous vraiment supprimer cet article ?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Annuler",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteArticle(index);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Supprimer",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.red[600]),
                        ),
                        subtitle: Text(
                          "Total: ${articles[index].montantTotalHT} DH",
                        ),
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                      SizedBox(height: 15.0),
                    ],
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2D9CDB),
        foregroundColor: Colors.white,
        onPressed: () {
          _descriptionController.clear();
          _prixUnitaireController.clear();
          _quantiteController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  double prix =
                      double.tryParse(_prixUnitaireController.text) ?? 0.0;
                  int qtt = int.tryParse(_quantiteController.text) ?? 0;
                  double montant = Article.montantTotalHT2(prix, qtt);

                  bool isPrixValid = prix > 0;
                  bool isQttValid = qtt > 0;

                  return AlertDialog(
                    backgroundColor: Colors.white,
                    scrollable: true,
                    content: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Description d'article",
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _quantiteController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Quantité d'article",
                              errorText:
                                  !isQttValid &&
                                          _quantiteController.text.isNotEmpty
                                      ? "Quantité doit être positive"
                                      : null,
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _prixUnitaireController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Prix unitaire d'article",
                              errorText:
                                  !isPrixValid &&
                                          _prixUnitaireController
                                              .text
                                              .isNotEmpty
                                      ? "Prix doit être positif"
                                      : null,
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 15),
                          Text("Montant total: $montant DH"),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2D9CDB),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isPrixValid &&
                                    isQttValid &&
                                    _descriptionController.text.isNotEmpty) {
                                  addArticle();
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: Text("Ajouter"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_frames_rounded),
            label: "Page des factures",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: "Liste des articles",
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFD8ECFF),
        backgroundColor: const Color(0xFF2D9CDB),
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FacturePage()),
              );
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
