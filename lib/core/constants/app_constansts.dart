import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const String welcomeMsg = "Hello, Welcome 👋";
  static const String searchProducts = "Search products..";
  static const String totalCategories = "Total Categories";
  static const String categories = "Categories";
  static const String addCategory = "Add Category";
  static const String categoryAdded = "Category added successfully ✅";
  static const String addProduct = "Add Product";
  static const String productAdded = "Product added successfully ✅";
  static const String updtCategory = "Update Category";
  static const String updtProduct = "Update Product";
  static const String productUpdated = "Product Updated successfully ✅";
  static const String updtOrder = "Update Order";
  static const String orderStatus = "Order Status";
  static const String orderID = "Order ID";
  static const String orderNo = "Order Number";
  static const String userID = "User ID";
  static const String updtOrderStatus = "Update Order Status";
  static const String orderStatusUpdated = "Order Status Update successfully ✅";
  static const String title = "Title";
  static const String slug = "Slug";
  static const String activeStatus = "Active status";
  static const String totalOrders = "Total Orders";
  static const String totalUsers = "Total Users";
  static const String addUser = "Add User";
  static const String userCreated = "User Created successfully ✅";
  static const String productDeleted = "Product Deleted successfully ✅";
  static const String categoryDeleted = "Category Deleted successfully ✅";
  static const String active = "Active";
  static const String pending = "Pending";
  static const String confirmed = "Confirmed";
  static const String inActive = "Inactive";
  static const String products = "Products";
  static const String home = "Home";
  static const String search = "Search";
  static const String cart = "Cart";
  static const String cartProducts = "Cart Products";
  static const String menu = "Menu";
  static const String ourProducts = "Our Products";
  static const String seeAll = "See all";
  static const String adminDashBoard = "Admin Dashboard";
  static const String users = "Users";
  static const String orders = "Orders";
  static const String revenue = "Revenue";
  static const String welcomeMsgLogin = "Welcome to Marketly";
  static const String signInToContinue = "Sign in to continue";
  static const String login = "Login";
  static const String signup = "Sign up";
  static const String register = "Register";
  static const String dontHaveAccount = "Don't have an Account!";
  static const String haveAnAccount = "Already have an Account!";
  static const String registerNow = "$register now";
  static const String getStartedMsg = "Get started with Marketly";
  static const String signUpToContinue = "Sign up to continue";
  static const String upldProfilePic = "Upload profile picture (optional)";
  static const String upldThumbnail = "Upload thumbnail image";
  static const String upldProductImages = "Upload product images";
  static const String imgSelected = "Image selected";
  static const String noProductFound = "No products found";
  static const String emptyCartMsg = "Cart is Empty";
  static const String addedToCart = "Product added to cart";
  static const String deleteProduct = "Delete Product";
  static const String back = "Back";
  static const String next = "Next";
  static const String cancel = "Cancel";
  static const String delete = "Delete";
  static const String deleteAcc = "Delete Account";
  static const String cancelCheckOut = "Cancel checkout?";
  static const String areYouSureCancelCheckOut =
      "Are you sure you wnat to cancel check out process?";
  static const String areYouSureDeleteAdrs =
      "Are you sure you want to delete this address?";
  static const String areYouSureDeleteProduct =
      "Are you sure you want to delete this product?";
  static const String areYouSureEmptyCart =
      "Are you sure you want to remove all items from your cart?\nThis action can’t be undone.";
  static const String areYouSureDeleteCate =
      "Are you sure you want to delete this category?";
  static const String areYouSureDeleteAccount =
      "Are you sure you want to delete this Account?";
  static const String yes = "Yes";
  static const String no = "No";
  static const String myAccount = "My Account";
  static const String savedAdrs = "Saved Addresses";
  static const String myOrders = "My Orders";
  static const String myCart = "My Cart";
  static const String logout = "Logout";
  static const String defaultAdrs = "Default address";
  static const String addNewAdrs = "Add new address";
  static const String dialogEmptyCart = "Empty cart?";
  static const String yesEmptyCart = "Yes, empty cart";

  // User Constants
  static const String usrDetails = "User Details";
  static const String username = "Username";
  static const String email = "Email";
  static const String pass = "Password";
  static const String confPass = "Confirm password";
  static const String phone = "Phone number";
  static const String adrs = "Address";
  static const String selectAdrs = "Select Address";
  static const String ct = "City";
  static const String state = "State";
  static const String cntry = "Country";
  static const String pincode = "Pincode";

  // Product Constants
  static const String description = "Description";
  static const String category = "Category";
  static const String brand = "Brand";
  static const String stock = "Stock";
  static const String weight = "Weight";
  static const String tags = "Tags";
  static const String tagsFieldHint = "Enter multiple tags , speparated";
  static const String price = "Price";
  static const String rating = "Rating";
  static const String dimensions = "Dimensions";
  static const String height = "Height";
  static const String width = "Width";
  static const String depth = "Depth";
  static const String thubnailImg = "Thumbnail Image";
  static const String images = "Images";
  static const String subtotal = "Subtotal";
  static const String discount = "Discount";
  static const String itemFinalTot = "Item final total";
  static const String basePrice = "Base Price";
  static const String qty = "Qty";
  static const String total = "Total";
  static const String placeOrder = "Place Order";
  static const String orderPlacedMsg = "Order placed successfully 🎉";
  static const String noOrder = "No Order History!";
  static const String viewOrderDetails = "View Order details";
  static const String orderDetails = "Order details";
  static const String fonalOrderSummary = "Final Order Summary";
  static const String paymentMethod = "Payment Method";
  static const String upi = "UPI";
  static const String card = "Card";
  static const String cod = "Cash on Delivery";
  static const String orderSummary = "Order Summary";
  static const String paymentDetails = "Payment Details";
  static const String totalProducts = "Total Products";
  static const String totalQuantity = "Total of Quantity";
  static const String goTocheckOut = "Go to Check Out!";

  static String dolrAmount(double amount) {
    return "\$ ${amount.toStringAsFixed(2)}";
  }

  static String discountOff(double discount) {
    return "${discount.toStringAsFixed(2)}% off ";
  }

  static String formatedDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();

    final date = DateFormat('d MMMM yyyy').format(dateTime);

    return date;
  }

  static String formatedTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final time = DateFormat('HH:mm').format(dateTime);
    return time;
  }
}
