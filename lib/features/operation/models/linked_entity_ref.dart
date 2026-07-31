import 'package:flutter/material.dart';

@immutable
class LinkedEntityRef {
  final String type, id;
  final String? label;
  const LinkedEntityRef({required this.type, required this.id, this.label});
  @override
  bool operator ==(Object o) =>
      o is LinkedEntityRef && o.type == type && o.id == id;
  @override
  int get hashCode => Object.hash(type, id);
}
