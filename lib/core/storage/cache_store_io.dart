import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:homio_essentials/core/storage/cache_store.dart';

Future<CacheStore> openStore() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}/archive');
  await dir.create(recursive: true);
  return _FileStore(dir);
}

class _FileStore implements CacheStore {
  _FileStore(this.dir);
  final Directory dir;

  File _f(String key) => File('${dir.path}/${key.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_')}.json');

  @override
  Future<String?> read(String key) async {
    final f = _f(key);
    return await f.exists() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String key, String value) async {
    final tmp = File('${_f(key).path}.tmp');
    await tmp.writeAsString(value, flush: true);
    await tmp.rename(_f(key).path); // atomic replace: a crash never leaves half a file
  }

  @override
  Future<void> delete(String key) async {
    final f = _f(key);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<int> sizeBytes() async {
    var n = 0;
    await for (final e in dir.list()) {
      if (e is File) n += await e.length();
    }
    return n;
  }
}
