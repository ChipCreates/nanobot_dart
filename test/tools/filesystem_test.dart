import 'dart:io';

import 'package:nanobot_dart/src/agent/tools/filesystem.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FilesystemTools', () {
    late Directory tempDir;
    late String workspacePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('nanobot_fs_test_');
      workspacePath = tempDir.path;
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('Sandboxing', () {
      test('valid path returns absolute path', () {
        final tool = ReadFileTool(workspacePath: workspacePath);
        final path = tool.validatePath('file.txt');
        expect(path, equals(p.canonicalize(p.join(workspacePath, 'file.txt'))));
      });

      test('accessing outside workspace throws exception', () {
        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.validatePath('../outside.txt'),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('accessing absolute path outside workspace throws exception', () {
        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.validatePath('/tmp/outside.txt'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('WriteFileTool', () {
      test('writes file content', () async {
        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool.execute({'path': 'test.txt', 'content': 'Hello'});

        final file = File(p.join(workspacePath, 'test.txt'));
        expect(file.existsSync(), isTrue);
        expect(await file.readAsString(), 'Hello');
      });

      test('overwrites file content', () async {
        final file = File(p.join(workspacePath, 'test.txt'));
        await file.writeAsString('Old');

        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool.execute({'path': 'test.txt', 'content': 'New'});

        expect(await file.readAsString(), 'New');
      });

      test('appends file content', () async {
        final file = File(p.join(workspacePath, 'test.txt'));
        await file.writeAsString('Old');

        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool
            .execute({'path': 'test.txt', 'content': 'New', 'append': true});

        expect(await file.readAsString(), 'OldNew');
      });

      test('creates directories recursively', () async {
        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool.execute({'path': 'deep/nested/file.txt', 'content': 'data'});

        final file = File(p.join(workspacePath, 'deep/nested/file.txt'));
        expect(file.existsSync(), isTrue);
      });
    });

    group('ReadFileTool', () {
      test('reads file content', () async {
        final file = File(p.join(workspacePath, 'read.txt'));
        await file.writeAsString('Content');

        final tool = ReadFileTool(workspacePath: workspacePath);
        final result = await tool.execute({'path': 'read.txt'});

        expect(result, 'Content');
      });

      test('throws if file does not exist', () async {
        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.execute({'path': 'non_existent.txt'}),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('ListDirTool', () {
      test('lists directory contents', () async {
        Directory(p.join(workspacePath, 'subdir')).createSync();
        File(p.join(workspacePath, 'subdir', 'file1.txt')).createSync();
        File(p.join(workspacePath, 'subdir', 'file2.txt')).createSync();

        final tool = ListDirTool(workspacePath: workspacePath);
        final result = await tool.execute({'path': 'subdir'});

        expect(result, contains('file1.txt'));
        expect(result, contains('file2.txt'));
        expect(result, contains('[FILE]'));
      });

      test('lists workspace root by default', () async {
        File(p.join(workspacePath, 'root.txt')).createSync();

        final tool = ListDirTool(workspacePath: workspacePath);
        final result = await tool.execute({});

        expect(result, contains('root.txt'));
      });
    });
  });
}
