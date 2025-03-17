import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:copy_with/copy_with.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:source_gen/source_gen.dart';
import 'package:package_config/package_config.dart';

class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final config = newCopyWithAnnotation(annotation);
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    // parsing
    final obj = <String, dynamic>{};
    obj["name"] = visitor.className;
    obj["properties"] = [];
    for (final field in visitor.fields.keys) {
      obj["properties"].add({
        "name": field,
        "type": visitor.fields[field],
      });
    }

    final cwd = Directory.current;
    String folder = "${cwd.path}/${config.templates}";
    if (config.templates == null) {
      final packageConfig = await findPackageConfig(cwd);
      final package = packageConfig?.packages.firstWhere(
        (p) => p.name == 'copy_with_gen',
      );
      folder = package!.packageUriRoot.resolve("templates").toFilePath();
    }
    final templates = Platform.script.resolve(folder).toFilePath();
    print(templates);
    var env = Environment(
      globals: <String, Object?>{},
      autoReload: false,
      loader: FileSystemLoader(paths: <String>[templates]),
      leftStripBlocks: true,
      trimBlocks: true,
    );
    final code = env.getTemplate('copy_with.dart.jinja').render(obj);
    return code;
  }
}

CopyWith newCopyWithAnnotation(ConstantReader annotation) {
  return CopyWith(
    templates: annotation.read("templates").isNull
        ? null
        : annotation.read("templates").stringValue,
  );
}

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  final fields = <String, dynamic>{};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  void visitFieldElement(FieldElement element) {
    if (element.getter?.metadata.isNotEmpty ?? false) {
      for (var meta in element.getter!.metadata) {
        if (meta.isOverride) {
          return;
        }
      }
    }
    final elementType = element.type.toString();
    fields[element.name] = elementType.replaceFirst('*', '');
  }
}
