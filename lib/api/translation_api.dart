import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class TranslationApi {
  static final _apiKey = 'AIzaSyCKg-8KXrMIryYwif8C4gEFSu4aKXLK3as';

  Future<String> translate2(String message, String toLanguageCode) async {
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=$message'),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;

      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }

  Future<String> translate(
      String message, String fromLanguageCode, String toLanguageCode) async {
    final translation = await GoogleTranslator().translate(
      message,
    //   from: fromLanguageCode,
      to: toLanguageCode,
    );

    return translation.text;
  }
}