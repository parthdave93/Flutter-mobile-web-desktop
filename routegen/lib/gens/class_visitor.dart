import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';

class ClassVisitor  extends SimpleElementVisitor {
  DartType className;
  String constructorDocumentComment;
  List<ParameterElement> constructorParameters;
  Map<String, DartType> fields = Map();

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
    constructorDocumentComment = element.documentationComment;
    constructorParameters = element.parameters;
    return super.visitConstructorElement(element);
  }

  @override
  visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;

    return super.visitFieldElement(element);
  }
}