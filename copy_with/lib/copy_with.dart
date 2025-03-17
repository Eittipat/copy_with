library;

import 'package:meta/meta_meta.dart';

/// A class annotation that generates copyWith functionality for Dart classes.
///
/// When applied to a class, this annotation will generate the necessary code
/// to create modified copies of instances of that class. This is particularly
/// useful for immutable classes where you need to create new instances with
/// slight modifications.
///
/// Example usage:
/// ```dart
/// @CopyWith()
/// class Person {
///   final String name;
///   final int age;
///
///   const Person({required this.name, required this.age});
/// }
/// ```
///
/// The generated code will allow you to create copies like:
/// ```dart
/// final person = Person(name: 'John', age: 30);
/// final olderPerson = person.copyWith(age: () => 31);
/// ```
@Target({TargetKind.classType})
class CopyWith {
  const CopyWith({
    this.templates,
  });

  /// The directory path containing custom templates for code generation.
  ///
  /// When specified, the generator will look for template files in this directory
  /// instead of using the default templates. This allows for customization of
  /// the generated copyWith implementation.
  ///
  /// If null, default templates will be used.
  final String? templates;
}
