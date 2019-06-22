import 'chapter.dart';
import 'novel.dart';

class Volume {
  int serial;
  String title;
  final Novel novel;

  Volume(
    this.novel, {
    this.serial,
    this.title,
  });

  @override
  int get hashCode => serial;

  @override
  bool operator ==(other) => other is Chapter && other.serial == serial;

  Stream<Chapter> get chapters async* {
    for (var chapter in novel.chapters) {
      if (chapter.volume.serial == serial) {
        yield chapter;
      }
    }
  }
}
