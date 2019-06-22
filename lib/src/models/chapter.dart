import 'package:meta/meta.dart';

import 'novel.dart';
import 'volume.dart';

class Chapter {
  int serial;
  String title;
  String content;
  String pageLink;
  final Volume volume;

  Chapter(
    this.volume, {
    @required this.serial,
    this.title,
    this.content,
    @required this.pageLink,
  });

  @override
  int get hashCode => serial;

  @override
  bool operator ==(other) => other is Chapter && other.serial == serial;

  Novel get novel => volume.novel;
}
