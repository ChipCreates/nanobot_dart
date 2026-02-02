import 'dart:io';

import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:path/path.dart' as p;

/// Base class for filesystem tools with sandboxing.
abstract class FilesystemTool extends Tool {
  FilesystemTool({required this.workspacePath});

  final String workspacePath;

  /// Validates that [path] is within [workspacePath].
  /// Returns the absolute path if valid, otherwise throws [FileSystemException].
  String validatePath(String path) {
    if (path.isEmpty) {
      throw const FileSystemException('Path cannot be empty');
    }

    // Normalize and resolve path
    final absoluteWorkspace = p.canonicalize(workspacePath);
    final absoluteTarget = p.canonicalize(p.join(workspacePath, path));

    if (!p.isWithin(absoluteWorkspace, absoluteTarget) &&
        absoluteWorkspace != absoluteTarget) {
      throw FileSystemException(
        'Access denied: Path is outside workspace',
        path,
      );
    }

    return absoluteTarget;
  }
}

/// Tool to read a file from the filesystem.
class ReadFileTool extends FilesystemTool {
  ReadFileTool({required super.workspacePath});

  @override
  String get name => 'read_file';

  @override
  String get description =>
      'Read the contents of a file. Returns the file content as a string.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'The path to the file to read, relative to workspace.',
          },
        },
        'required': ['path'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final path = params['path'] as String;
    final absolutePath = validatePath(path);
    final file = File(absolutePath);

    if (!file.existsSync()) {
      throw FileSystemException('File not found', path);
    }

    return file.readAsString();
  }
}

/// Tool to write content to a file.
class WriteFileTool extends FilesystemTool {
  WriteFileTool({required super.workspacePath});

  @override
  String get name => 'write_file';

  @override
  String get description =>
      'Write content to a file. Overwrites existing files unless append is true.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'The path to the file to write, relative to workspace.',
          },
          'content': {
            'type': 'string',
            'description': 'The content to write to the file.',
          },
          'append': {
            'type': 'boolean',
            'description':
                'If true, appends content to the file instead of overwriting.',
            'default': false,
          },
        },
        'required': ['path', 'content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final path = params['path'] as String;
    final content = params['content'] as String;
    final append = params['append'] as bool? ?? false;

    final absolutePath = validatePath(path);
    final file = File(absolutePath);

    // Ensure parent directory exists
    await file.parent.create(recursive: true);

    if (append) {
      await file.writeAsString(content, mode: FileMode.append);
      return 'Successfully appended to $path';
    } else {
      await file.writeAsString(content);
      return 'Successfully wrote to $path';
    }
  }
}

/// Tool to list directory contents.
class ListDirTool extends FilesystemTool {
  ListDirTool({required super.workspacePath});

  @override
  String get name => 'list_dir';

  @override
  String get description => 'List files and directories in a given path.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description': 'The directory path to list, relative to workspace.',
            'default': '.',
          },
        },
        'required': <String>[],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final path = params['path'] as String? ?? '.';
    final absolutePath = validatePath(path);
    final dir = Directory(absolutePath);

    if (!dir.existsSync()) {
      throw FileSystemException('Directory not found', path);
    }

    final entities = await dir.list().toList();
    final buffer = StringBuffer('Contents of $path:\n');

    for (final entity in entities) {
      final stat = await entity.stat();
      final type =
          stat.type == FileSystemEntityType.directory ? '[DIR]' : '[FILE]';
      final name = p.basename(entity.path);
      buffer.writeln('$type $name');
    }

    if (entities.isEmpty) {
      buffer.writeln('(empty)');
    }

    return buffer.toString();
  }
}
