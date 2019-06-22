import 'chapter.dart';
import 'volume.dart';

class Novel {
  String name;
  String pageLink;
  String summary;
  List<int> image;
  final Set<Volume> volumes = Set();
  final Set<Chapter> chapters = Set();
}
