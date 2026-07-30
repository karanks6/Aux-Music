import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'dart:io';

void main() async {
  final feeds = [
    'https://feeds.simplecast.com/dHoohVNH', // Conan O'Brien
    'https://rss.art19.com/smartless', // SmartLess
    'https://wtfpod.libsyn.com/rss', // WTF with Marc Maron
  ];
  
  for (final feed in feeds) {
    try {
      final response = await Dio().get(feed);
      final document = XmlDocument.parse(response.data.toString());
      final channel = document.findAllElements('channel').first;
      final title = channel.findElements('title').firstOrNull?.innerText;
      print('$feed -> $title');
    } catch (e) {
      print('$feed -> ERROR');
    }
  }
}
