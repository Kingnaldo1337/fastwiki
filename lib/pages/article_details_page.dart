import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsPage extends StatefulWidget {
  final int pageId;
  final String title;

  ArticleDetailsPage({required this.pageId, required this.title});

  @override
  _ArticleDetailsPageState createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  late Future<Map<String, dynamic>> _articleDetails;

  @override
  void initState() {
    super.initState();
    _articleDetails = _fetchArticleDetails(widget.pageId);
  }

  Future<Map<String, dynamic>> _fetchArticleDetails(int pageId) async {
    final response = await http.get(Uri.parse(
        'https://pt.wikipedia.org/w/api.php?action=query&prop=extracts|pageimages|info&inprop=url&exintro&explaintext&format=json&pageids=$pageId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['query']['pages']['$pageId'];
    } else {
      throw Exception('Failed to load article details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _articleDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhum detalhe encontrado'));
          } else {
            final article = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (article['title'] != null)
                    Text(
                      article['title'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 20),
                  if (article['extract'] != null)
                    Text(
                      article['extract'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 20),
                  if (article['fullurl'] != null)
                    GestureDetector(
                                            onTap: () async {
                        final url = article['fullurl'];
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        'Leia mais na Wikipedia',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

