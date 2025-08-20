import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String label;
  final IconData iconData;
  final String? iconUrl; // For backend-provided icons
  final String? iconCode; // For icon code names from backend
  final String? iconBase64; // For base64 encoded icons
  final Color? color;
  final bool isActive;
  final int order;
  final String route;
  final Map<String, dynamic>? metadata;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.label,
    required this.iconData,
    this.iconUrl,
    this.iconCode,
    this.iconBase64,
    this.color,
    this.isActive = true,
    this.order = 0,
    required this.route,
    this.metadata,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      iconData: _getIconDataFromCode(json['iconCode']),
      iconUrl: json['iconUrl'],
      iconCode: json['iconCode'],
      iconBase64: json['iconBase64'],
      color: json['color'] != null ? Color(json['color']) : null,
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
      route: json['route'] ?? '',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'iconCode': iconCode,
      'iconUrl': iconUrl,
      'iconBase64': iconBase64,
      'color': color?.value,
      'isActive': isActive,
      'order': order,
      'route': route,
      'metadata': metadata,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? label,
    IconData? iconData,
    String? iconUrl,
    String? iconCode,
    String? iconBase64,
    Color? color,
    bool? isActive,
    int? order,
    String? route,
    Map<String, dynamic>? metadata,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      iconData: iconData ?? this.iconData,
      iconUrl: iconUrl ?? this.iconUrl,
      iconCode: iconCode ?? this.iconCode,
      iconBase64: iconBase64 ?? this.iconBase64,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      route: route ?? this.route,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method to convert icon code to IconData
  static IconData _getIconDataFromCode(String? iconCode) {
    if (iconCode == null) return Icons.category;
    
    switch (iconCode.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'note':
      case 'notes':
        return Icons.note_alt;
      case 'video':
      case 'lectures':
        return Icons.video_library;
      case 'game':
      case 'gamification':
        return Icons.gamepad;
      case 'medication':
      case 'drug':
      case 'drugs':
        return Icons.medication;
      case 'quiz_outlined':
        return Icons.quiz_outlined;
      case 'book':
      case 'books':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'library':
        return Icons.library_books;
      case 'science':
        return Icons.science;
      case 'medical':
        return Icons.medical_services;
      case 'pets':
        return Icons.pets;
      case 'agriculture':
        return Icons.agriculture;
      default:
        return Icons.category;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.label == label;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ label.hashCode;
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, label: $label, iconCode: $iconCode, isActive: $isActive)';
  }
}