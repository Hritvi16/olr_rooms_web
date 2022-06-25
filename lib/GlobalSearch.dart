import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';
import 'package:olr_rooms_web/model/SearchResponse.dart';

class GlobalSearch {

  Future<List<SearchInfo>> search(String value) async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getBySearch,
      "search": value,
    };
    SearchResponse searchResponse = await APIService().search(data);
    print("searchResponse.toJson()");
    print(searchResponse.toJson());
    print(value);
    print(value.isEmpty);
    print(searchResponse.data);

    return value.isEmpty ? [] : searchResponse.data ?? [];

  }
}