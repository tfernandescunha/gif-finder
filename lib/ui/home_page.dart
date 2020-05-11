import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giffinder/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

import 'container_loader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (this._search == null || this._search.isEmpty) {
      response = await http.get('https://api.giphy'
          '.com/v1/gifs/trending?api_key=t30ffAGksaCfZx4eQ0iqF2gkjbRI274u&limit=20&rating=G');
    } else {
      response = await http.get('https://api.giphy'
          '.com/v1/gifs/search?api_key=t30ffAGksaCfZx4eQ0iqF2gkjbRI274u'
          '&q=${this._search}&limit=19&offset=${this._offset}&rating=G&lang=en');
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    this._getGifs().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title:
              Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextField(
                onSubmitted: (text) {
                  setState(() {
                    this._search = text;
                    this._offset = 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pesquise aqui',
                ),
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: FutureBuilder(
                    future: this._getGifs(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return ContainerLoader();
                        default:
                          if (snapshot.hasError)
                            return Container();
                          else
                            return _createGifTable(context, snapshot);
                      }
                    }),
              )
            ],
          ),
        ));
  }

  int _getCount(List data) {
    if (this._search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: this._getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          return this._getGridTile(context, snapshot, index);
        });
  }

  Widget _getGridTile(BuildContext context, AsyncSnapshot snapshot, int index) {
    if (this._search == null || index < snapshot.data["data"].length) {
      return GestureDetector(
        child: Image.network(
          snapshot.data["data"][index]["images"]["fixed_height"]["url"],
          height: 300,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
        },
        onLongPress: () {
          Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
        },
      );
    } else {
      return Container(
        child: GestureDetector(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
                size: 70.0,
              ),
              Text(
                'Carregar mais...',
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              )
            ],
          ),
          onTap: () {
            setState(() {
              this._offset += 19;
              print(this._offset);
            });
          },
        ),
      );
    }
  }
}
