import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/widgets/custom_app_bar.dart';
import './article_details_page.dart';

class UFRNPage extends StatefulWidget {
  @override
  _UFRNPageState createState() => _UFRNPageState();
}

class _UFRNPageState extends State<UFRNPage> {
  List _ufrnResults = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUFRNArticles();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUFRNArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final response = await http.get(Uri.parse(
          'https://pt.wikipedia.org/w/api.php?action=query&list=search&srsearch=UFRN&srlimit=10&sroffset=${_currentPage * 10}&format=json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['query']['search'];

        setState(() {
          _ufrnResults.addAll(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load UFRN articles');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar artigos da UFRN: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchUFRNArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'UFRN'),
      body: _isLoading && _ufrnResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _ufrnResults.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _ufrnResults.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListTile(
                  leading: Icon(Icons.article, color: Colors.deepPurple),
                  title: Text(
                    _ufrnResults[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _ufrnResults[index]['snippet']
                        .replaceAll(RegExp(r'<[^>]*>'), ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    final pageId = _ufrnResults[index]['pageid'];
                    final intPageId = pageId is int
                        ? pageId
                        : int.tryParse(pageId.toString()) ?? 0;

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ArticleDetailsPage(
                          pageId: intPageId,
                          title: _ufrnResults[index]['title'] ??
                              'Detalhes do Artigo',
                        ),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
