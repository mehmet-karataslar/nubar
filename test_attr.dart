import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  final controller = QuillController.basic();
  controller.formatSelection(Attribute.fromKeyValue('size', 28.0));
  debugPrint(controller.getSelectionStyle().attributes.toString());
}
