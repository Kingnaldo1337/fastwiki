import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_details_page.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/custom_app_bar.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List _searchResults = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMoreResults = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchWikipedia(String query, {bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMoreResults) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://pt.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&format=json&srlimit=$_pageSize&sroffset=${_currentPage * _pageSize}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['query']['search'];

        setState(() {
          if (isLoadMore) {
            _searchResults.addAll(data);
          } else {
            _searchResults = data;
          }

          _hasMoreResults = data.length == _pageSize;
          _isLoading = false;
          _currentPage++;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro durante a pesquisa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Página de Pesquisa'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Digite sua pesquisa',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _currentPage = 0;
                  _hasMoreResults = true;
                  _searchWikipedia(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading && _searchResults.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            _hasMoreResults &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          _searchWikipedia(_searchText, isLoadMore: true);
                        }
                        return false;
                      },
                      child: _buildSearchResults(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('Nenhum resultado encontrado'));
    } else {
      return ListView.builder(
        itemCount: _searchResults.length + (_hasMoreResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _searchResults.length && _hasMoreResults) {
            return const Center(child: CircularProgressIndicator());
          }
          return SearchResultTile(article: _searchResults[index]);
        },
      );
    }
  }
}
