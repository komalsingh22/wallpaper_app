import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wallpaper_setter_app/constants/constants.dart';
import 'package:wallpaper_setter_app/full_screen.dart';
class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});
  
  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  List images=[];
  int page=1;
  @override
  void initState() {
    super.initState();
    fetchApi();
  }

  fetchApi() async {
     await http.get(
      Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
      headers: {
        'Authorization': apikey, // Replace with your actual API key
      },
    ).then((value){
      Map result = jsonDecode(value.body);
      setState(() {
        images = result['photos'];
      });
     // print(images[0]);

    });
  }
  loadMore() async{
    setState(() {
      page++;
    });
    String url=
    'https://api.pexels.com/v1/curated?per_page=80&page=$page';

    await http.get(Uri.parse(url),headers: {
      'Authorization': apikey,
    }).then((value){
      Map result = jsonDecode(value.body);
      setState(() {
        images.addAll(result['photos']);
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 2 / 3,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)
                    =>FullScreen(image: images[index]['src']['large'])));
                  },
                  child: Image.network(
                    images[index]['src']['tiny'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          InkWell(
            onTap: (){
              loadMore();
            },
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Load More',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
