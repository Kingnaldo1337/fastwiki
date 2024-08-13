import 'package:flutter/material.dart';
import '/pages/article_details_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/widgets/custom_app_bar.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List _trendingResults = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMoreResults = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTrendingTopics();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrendingTopics() async {
    if (!_hasMoreResults) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://pt.wikipedia.org/w/api.php?action=query&list=mostviewed&pvimlimit=$_pageSize&pvimoffset=${_currentPage * _pageSize}&format=json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['query']['mostviewed'];

        setState(() {
          _trendingResults.addAll(data);
          _isLoading = false;
          _hasMoreResults = data.length == _pageSize;
        });
        _currentPage++;
      } else {
        throw Exception('Failed to load trending topics');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar os tópicos em alta: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchTrendingTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Tópicos em Alta'),
      body: _isLoading && _trendingResults.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _trendingResults.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _trendingResults.length) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListTile(
                  leading: Icon(Icons.trending_up, color: Colors.deepPurple),
                  title: Text(
                    _trendingResults[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Visualizações: ${_trendingResults[index]['count']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    final pageId = _trendingResults[index]['pageid'];
                    final intPageId = pageId is int
                        ? pageId
                        : int.tryParse(pageId.toString()) ?? 0;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailsPage(
                          pageId: intPageId,
                          title: _trendingResults[index]['title'] ??
                              'Detalhes do Artigo',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
