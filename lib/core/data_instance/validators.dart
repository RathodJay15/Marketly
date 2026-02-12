import 'dart:io';

class Validators {
  // Username
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    return null;
  }

  //  Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password
  // Minimum 8 characters, 1 number, 1 special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,}$');

    if (!passwordRegex.hasMatch(value)) {
      return 'Enter at least 8 characters & include a number & special character';
    }

    return null;
  }

  // Confirm Password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone Number (10 digits)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  // Address
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 10) {
      return 'Address is too short';
    }

    return null;
  }

  // City
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }

    return null;
  }

  // State
  static String? state(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }

    return null;
  }

  // Country
  static String? country(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }

    return null;
  }

  // Pin code (6 digits)
  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pin code is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{6}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 6-digit Pin code';
    }

    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  static String? slug(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Slug is required';
    }

    final slug = value.trim();

    // No spaces allowed
    if (slug.contains(' ')) {
      return 'Use "-" instead of spaces';
    }

    // Only lowercase letters, numbers and hyphen allowed
    final slugRegex = RegExp(r'^[a-z0-9-]+$');
    if (!slugRegex.hasMatch(slug)) {
      return 'Only lowercase letters, numbers and "-" allowed';
    }
    return null;
  }

  // ---------------- REQUIRED TEXT ----------------
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
  }

  // ---------------- PRICE ----------------
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Price is required";
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return "Enter valid price";
    }

    return null;
  }

  // ---------------- DISCOUNT ----------------
  static String? discount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Discount is required";
    }

    final discount = double.tryParse(value);
    if (discount == null || discount < 0 || discount > 100) {
      return "Discount must be 0 - 100";
    }

    return null;
  }

  // ---------------- RATING ----------------
  static String? rating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Rating is required";
    }

    final rating = double.tryParse(value);
    if (rating == null || rating < 0 || rating > 5) {
      return "Rating must be 0 - 5";
    }

    return null;
  }

  // ---------------- STOCK ----------------
  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Stock is required";
    }

    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return "Enter valid stock";
    }

    return null;
  }

  // ---------------- CATEGORY ----------------
  static String? category(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please select category";
    }
    return null;
  }

  // ---------------- THUMBNAIL ----------------
  static String? thumbnail(File? file) {
    if (file == null) {
      return "Thumbnail is required";
    }
    return null;
  }

  // ---------------- PRODUCT IMAGES ----------------
  static String? productImages(List<File>? files) {
    if (files == null || files.isEmpty) {
      return "At least 1 product image required";
    }
    return null;
  }
}
