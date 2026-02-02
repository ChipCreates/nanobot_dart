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

    group('EditFileTool', () {
      test('replaces text in file', () async {
        final file = File(p.join(workspacePath, 'edit.txt'));
        await file.writeAsString('Hello World');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'edit.txt',
          'old_text': 'World',
          'new_text': 'Dart',
        });

        expect(result, contains('Successfully edited'));
        expect(await file.readAsString(), 'Hello Dart');
      });

      test('returns error for non-existent file', () async {
        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'non_existent.txt',
          'old_text': 'foo',
          'new_text': 'bar',
        });

        expect(result, contains('File not found'));
      });

      test('returns error when old_text not found', () async {
        final file = File(p.join(workspacePath, 'edit.txt'));
        await file.writeAsString('Hello World');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'edit.txt',
          'old_text': 'Goodbye',
          'new_text': 'Hi',
        });

        expect(result, contains('not found in file'));
      });

      test('warns when old_text appears multiple times', () async {
        final file = File(p.join(workspacePath, 'edit.txt'));
        await file.writeAsString('foo bar foo');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'edit.txt',
          'old_text': 'foo',
          'new_text': 'baz',
        });

        expect(result, contains('appears 2 times'));
        // File should not be modified
        expect(await file.readAsString(), 'foo bar foo');
      });

      test('handles multiline replacement', () async {
        final file = File(p.join(workspacePath, 'edit.txt'));
        await file.writeAsString('line1\nold content\nline3');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'edit.txt',
          'old_text': 'old content',
          'new_text': 'new content\nextra line',
        });

        expect(result, contains('Successfully edited'));
        expect(
          await file.readAsString(),
          'line1\nnew content\nextra line\nline3',
        );
      });
    });

    group('Edge Cases', () {
      test('EditFileTool with empty file', () async {
        final file = File(p.join(workspacePath, 'empty.txt'));
        await file.writeAsString('');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'empty.txt',
          'old_text': 'anything',
          'new_text': 'something',
        });

        expect(result, contains('not found in file'));
      });

      test('EditFileTool where file is only old_text', () async {
        final file = File(p.join(workspacePath, 'only.txt'));
        await file.writeAsString('ONLY');

        final tool = EditFileTool(workspacePath: workspacePath);
        await tool.execute({
          'path': 'only.txt',
          'old_text': 'ONLY',
          'new_text': 'REPLACED',
        });

        expect(await file.readAsString(), 'REPLACED');
      });

      test('WriteFileTool with null append (default false)', () async {
        final file = File(p.join(workspacePath, 'append_test.txt'));
        await file.writeAsString('Initial');

        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool.execute({
          'path': 'append_test.txt',
          'content': 'Overwritten',
        });

        expect(await file.readAsString(), 'Overwritten');
      });

      test('validatePath prevents directory traversal with multiple dots', () {
        final tool = ListDirTool(workspacePath: workspacePath);
        expect(
          () => tool.validatePath('sub/../../outside.txt'),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('ListDirTool handles mixed file and directory', () async {
        await Directory(p.join(workspacePath, 'subdir')).create();
        await File(p.join(workspacePath, 'file.txt')).writeAsString('content');

        final tool = ListDirTool(workspacePath: workspacePath);
        final result = await tool.execute({'path': '.'});

        expect(result, contains('[DIR] subdir'));
        expect(result, contains('[FILE] file.txt'));
      });

      test('ReadFileTool fails on directory', () async {
        await Directory(p.join(workspacePath, 'subdir')).create();

        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.execute({'path': 'subdir'}),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('WriteFileTool appends content', () async {
        const path = 'append_test.txt';
        final absolutePath = p.join(workspacePath, path);
        final file = File(absolutePath);
        await file.writeAsString('Line 1\n');

        final tool = WriteFileTool(workspacePath: workspacePath);
        await tool.execute({
          'path': path,
          'content': 'Line 2',
          'append': true,
        });

        expect(await file.readAsString(), 'Line 1\nLine 2');
      });

      test('ListDirTool fails on file', () async {
        final file = File(p.join(workspacePath, 'not_a_dir.txt'));
        await file.writeAsString('I am a file');

        final tool = ListDirTool(workspacePath: workspacePath);
        expect(
          () => tool.execute({'path': 'not_a_dir.txt'}),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('EditFileTool warns on multiple occurrences', () async {
        final file = File(p.join(workspacePath, 'multi.txt'));
        await file.writeAsString('repeat repeat repeat');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'multi.txt',
          'old_text': 'repeat',
          'new_text': 'single',
        });
        expect(result, contains('Warning: old_text appears 3 times'));
      });

      test('ListDirTool handles empty directory', () async {
        final dir = Directory(p.join(workspacePath, 'empty_dir'));
        await dir.create();

        final tool = ListDirTool(workspacePath: workspacePath);
        final result = await tool.execute({'path': 'empty_dir'});
        expect(result, contains('(empty)'));
      });

      test('EditFileTool handles missing old_text', () async {
        final file = File(p.join(workspacePath, 'missing.txt'));
        await file.writeAsString('hello world');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'missing.txt',
          'old_text': 'nonexistent',
          'new_text': 'new',
        });
        expect(result, contains('Error: old_text not found'));
      });

      test('EditFileTool handles old_text == new_text', () async {
        final file = File(p.join(workspacePath, 'same.txt'));
        await file.writeAsString('hello');

        final tool = EditFileTool(workspacePath: workspacePath);
        final result = await tool.execute({
          'path': 'same.txt',
          'old_text': 'hello',
          'new_text': 'hello',
        });
        expect(result, contains('Successfully edited'));
      });

      test('ReadFileTool handles non-existent file', () async {
        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.execute({'path': 'nonexistent.txt'}),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('FilesystemTool.execute throws ArgumentError on missing path',
          () async {
        final tool = ReadFileTool(workspacePath: workspacePath);
        expect(
          () => tool.execute({}),
          throwsArgumentError,
        );
      });

      test('FilesystemTool validatePath handles empty path', () {
        final tool = ListDirTool(workspacePath: workspacePath);
        expect(
          () => tool.validatePath(''),
          throwsA(isA<FileSystemException>()),
        );
      });
    });
  });
}
