import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(NewsApp());
}

class NewsItem {
  final String imageUrl;
  final String title;
  final String description;
  final String content;
  final String author;
  final String url;

  NewsItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.url,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      imageUrl: json['urlToImage'] ?? "[object ProgressEvent]",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      content: json['content'] ?? "",
      author: json['author'] ?? "",
      url: json['url'] ?? "",
    );
  }
}

class NewsApp extends StatefulWidget {
  @override
  _NewsAppState createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  List<NewsItem> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=id'),
      headers: {'Authorization': 'Bearer af812361a60c404293eccaa2b06c30a1'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        newsList = (data['articles'] as List)
            .map((item) => NewsItem.fromJson(item))
            .toList();
      });
    } else {
      print('Failed to fetch data');
    }
  }

  void viewNewsDetails(NewsItem news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(news: news),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('News'),
        ),
        body: ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => viewNewsDetails(newsList[index]),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: newsList[index].imageUrl != "[object ProgressEvent]"
                          ? Image.network(
                              newsList[index].imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Placeholder(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            newsList[index].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            newsList[index].description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Author: ${newsList[index].author}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'URL: ${newsList[index].url}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsItem news;

  NewsDetailPage({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(news.content),
            SizedBox(height: 8),
            Text(
              'Author: ${news.author}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'URL: ${news.url}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}