import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/data/services/image_service.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:provider/provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _addPructState();
}

class _addPructState extends State<AddProduct> {
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController categoryCtrl = TextEditingController();
  TextEditingController discountCtrl = TextEditingController();
  TextEditingController ratingCtrl = TextEditingController();
  TextEditingController stockCtrl = TextEditingController();
  TextEditingController tagsCtrl = TextEditingController();
  TextEditingController brandCtrl = TextEditingController();
  TextEditingController weightCtrl = TextEditingController();
  TextEditingController heightCtrl = TextEditingController();
  TextEditingController widthCtrl = TextEditingController();
  TextEditingController depthCtrl = TextEditingController();

  File? _selectedThumbnail;
  List<File>? _selectedImages;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickThumbnail() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _selectedThumbnail = File(picked.path);
      });
    }
  }

  void _clearSelectedThumbnail() {
    setState(() {
      _selectedThumbnail = null;
    });
  }

  Future<void> _pickImages() async {
    final picked = await _imagePicker.pickMultiImage(
      limit: 10,
      imageQuality: 70,
    );

    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  void _clearSelectedImages() {
    setState(() {
      _selectedImages = null;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    categoryCtrl.dispose();
    discountCtrl.dispose();
    ratingCtrl.dispose();
    stockCtrl.dispose();
    tagsCtrl.dispose();
    brandCtrl.dispose();
    weightCtrl.dispose();
    heightCtrl.dispose();
    widthCtrl.dispose();
    depthCtrl.dispose();
    super.dispose();
  }

  // ---------------- Add ----------------
  Future<void> _onAdd() async {
    if (!_formKey.currentState!.validate()) return;

    final thumbnailError = Validators.thumbnail(_selectedThumbnail);
    if (thumbnailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(thumbnailError)));
      return;
    }

    final imagesError = Validators.productImages(_selectedImages);
    if (imagesError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(imagesError)));
      return;
    }

    final docRef = await context.read<ProductProvider>().createProduct(
      title: titleCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      category: categoryCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      discount: double.parse(discountCtrl.text.trim()),
      rating: double.parse(ratingCtrl.text.trim()),
      stock: int.parse(stockCtrl.text.trim()),
      tags: tagsCtrl.text.split(',').map((e) => e.trim()).toList(),
      brand: brandCtrl.text.trim(),
      weight: double.parse(weightCtrl.text.trim()),
      dimensions: {
        'height': double.parse(heightCtrl.text.trim()),
        'width': double.parse(widthCtrl.text.trim()),
        'depth': double.parse(depthCtrl.text.trim()),
      },
    );
    final thumbnailUrl = await _imageService.uploadProductThumbnail(
      productId: docRef.id,
      imageFile: _selectedThumbnail!,
    );
    final imageUrls = await _imageService.uploadProductImages(
      productId: docRef.id,
      imageFiles: _selectedImages!,
    );
    await docRef.update({'thumbnail': thumbnailUrl, 'images': imageUrls});
    // Proceed with add product
    await context.read<AdminDashboardProvider>().refreshDashboard();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.addProduct,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _detailsForm(),
    );
  }

  Widget _detailsForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _label(AppConstants.title),
          _field(
            titleCtrl,
            AppConstants.title,
            Validators.title,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.description),
          _field(
            descriptionCtrl,
            AppConstants.description,
            Validators.requiredField,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.category),
          _categoryDropdown(),

          _label(AppConstants.price),
          _field(
            priceCtrl,
            AppConstants.price,
            Validators.price,
            keyboardType: TextInputType.number,
          ),

          _label(AppConstants.discount),
          _field(
            discountCtrl,
            AppConstants.discount,
            Validators.discount,
            keyboardType: TextInputType.number,
          ),

          _label(AppConstants.rating),
          _field(
            ratingCtrl,
            AppConstants.rating,
            Validators.rating,
            keyboardType: TextInputType.number,
          ),

          _label(AppConstants.stock),
          _field(
            stockCtrl,
            AppConstants.stock,
            Validators.stock,
            keyboardType: TextInputType.number,
          ),

          _label(AppConstants.tags),
          _field(
            tagsCtrl,
            AppConstants.tagsFieldHint,
            Validators.requiredField,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.brand),
          _field(
            brandCtrl,
            AppConstants.brand,
            Validators.requiredField,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.weight),
          _field(
            weightCtrl,
            AppConstants.weight,
            Validators.requiredField,
            keyboardType: TextInputType.number,
          ),

          _label(AppConstants.dimensions),
          _dimensions(),

          _label(AppConstants.thubnailImg),

          if (_selectedThumbnail != null)
            _thumbnailPreview(imageFile: _selectedThumbnail),
          _thumbnailImageFormField(
            imageFile: _selectedThumbnail,
            onTap: _pickThumbnail,
          ),

          _label(AppConstants.images),
          if (_selectedImages != null)
            _imagesPreview(imageFiles: _selectedImages),
          _imagesFormField(imageFiles: _selectedImages, onTap: _pickImages),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _onAdd,
              child: Text(
                AppConstants.addProduct,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dimensions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.height,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              width: 120,
              child: _field(
                heightCtrl,
                AppConstants.height,
                Validators.requiredField,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.width,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              width: 120,
              child: _field(
                widthCtrl,
                AppConstants.width,
                Validators.requiredField,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.depth,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              width: 120,
              child: _field(
                depthCtrl,
                AppConstants.depth,
                Validators.requiredField,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        keyboardType: keyboardType,
        textInputAction: hint == AppConstants.depth
            ? TextInputAction.done
            : TextInputAction.next,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _categoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categories;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            validator: Validators.category,
            value: categoryCtrl.text.isEmpty ? null : categoryCtrl.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Theme.of(context).colorScheme.onSecondaryContainer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 16,
            ),
            hint: Text(
              AppConstants.category,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 16,
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.title, // change if you store id instead
                child: Text(category.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                categoryCtrl.text = value!;
              });
            },
          ),
        );
      },
    );
  }

  Widget _thumbnailPreview({required File? imageFile}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image(image: FileImage(imageFile!)),
      ),
    );
  }

  Widget _imagesPreview({required List<File>? imageFiles}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageFiles!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(image: FileImage(imageFiles[index])),
          );
        },
      ),
    );
  }

  Widget _thumbnailImageFormField({
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // left icon
              Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),

              const SizedBox(width: 12),

              // text / preview
              Expanded(
                child: imageFile == null
                    ? Text(
                        AppConstants.upldThumbnail,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        AppConstants.imgSelected,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 17,
                        ),
                      ),
              ),

              imageFile == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      icon: Icon(Icons.close),
                      onPressed: _clearSelectedThumbnail,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagesFormField({
    required List<File>? imageFiles,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // left icon
              Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),

              const SizedBox(width: 12),

              // text / preview
              Expanded(
                child: imageFiles == null
                    ? Text(
                        AppConstants.upldProductImages,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        AppConstants.imgSelected,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 17,
                        ),
                      ),
              ),

              imageFiles == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      icon: Icon(Icons.close),
                      onPressed: _clearSelectedImages,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
