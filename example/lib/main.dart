import 'package:copy_with/copy_with.dart';

part 'main.g.dart';

@CopyWith()
class ModelA {
  const ModelA({
    required this.id,
    required this.names,
    required this.price,
  });
  final int? id;
  final List<String> names;
  final double price;
}

void main() {
  print("Hello World");
}
