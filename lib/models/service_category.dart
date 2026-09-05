enum ServiceCategory {
  cleaning,
  cooking,
  childcare,
  laundry,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'Cleaning';
      case ServiceCategory.cooking:
        return 'Cooking';
      case ServiceCategory.childcare:
        return 'Childcare';
      case ServiceCategory.laundry:
        return 'Laundry';
    }
  }

  List<String> get subServices {
    switch (this) {
      case ServiceCategory.cleaning:
        return ['Deep Cleaning', 'Daily Cleaning', 'Kitchen Cleaning', 'Window Cleaning'];
      case ServiceCategory.cooking:
        return ['Daily Meals', 'Special Occasions', 'Baking', 'Dietary Specialization'];
      case ServiceCategory.childcare:
        return ['Nanny', 'Baby Sitting', 'Tutor', 'Elderly Care'];
      case ServiceCategory.laundry:
        return ['Clothes Washing', 'Ironing', 'Dry Cleaning'];
    }
  }
}
