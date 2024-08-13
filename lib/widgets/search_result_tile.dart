import 'package:flutter/material.dart';
import '../pages/article_details_page.dart';

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> article;

  SearchResultTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article['title']),
      subtitle: Text(
        _cleanSnippet(article['snippet']),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailsPage(
              pageId: article['pageid'],
              title: article['title'],
            ),
          ),
        );
      },
    );
  }

  String _cleanSnippet(String snippet) {
    // Remove as tags HTML que podem aparecer no snippet retornado pela API
    return snippet.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
