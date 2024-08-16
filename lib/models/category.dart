import 'package:flutter/material.dart';

enum Categories{
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class Category{
  const Category(this.categories,this.color);
  final String categories;
  final Color color;
}