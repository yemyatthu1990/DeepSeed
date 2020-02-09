import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiBaseHelper.dart';

class PhotoRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Photo>> fetchPhotoList(int pageNo) async {
    final response = await _helper.get(
        "photos/?page=$pageNo&&client_id=4b36820da7cb19e67bec552aa419229e012ed54d988b60f3f6db16e04082d2f4");

    List<Photo> results = new List<Photo>();
    response.forEach((v) {
      results.add(new Photo.fromJson(v));
    });
    return results;
  }
}
