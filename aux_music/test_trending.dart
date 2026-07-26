import 'package:dio/dio.dart';
import 'package:aux_music/data/models/track.dart';

void main() async {
  try {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    final response = await dio.get('/trending', queryParameters: {'language': 'hindi', 'limit': 20});
    final List<dynamic> data = response.data['data'];
    print('Data length: \${data.length}');
    for(var json in data) {
      try {
        Track.fromJson(json);
      } catch(e) {
        print('Failed on track: \${json["id"]} - \$e');
      }
    }
    print('Done');
  } catch(e) {
    print(e);
  }
}
