class FirestoreConstants {
  FirestoreConstants._();

  // Collection Names
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String productVariants = 'productVariants';
  static const String orders = 'orders';
  static const String orderItems = 'orderItems';
  static const String payments = 'payments';
  static const String paymentLogs = 'paymentLogs';
  static const String reviews = 'reviews';
  static const String wishlists = 'wishlists';
  static const String cart = 'cart';
  static const String addresses = 'addresses';
  static const String coupons = 'coupons';
  static const String notifications = 'notifications';
  static const String banners = 'banners';
  static const String inventory = 'inventory';
  static const String settings = 'settings';
  static const String supportTickets = 'supportTickets';
  static const String ticketMessages = 'ticketMessages';
  static const String analytics = 'analytics';

  // User Fields
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String phoneNumber = 'phoneNumber';
  static const String photoUrl = 'photoUrl';
  static const String role = 'role';
  static const String isEmailVerified = 'isEmailVerified';
  static const String fcmToken = 'fcmToken';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isActive = 'isActive';
  static const String isDeleted = 'isDeleted';

  // Product Fields
  static const String productName = 'name';
  static const String productSlug = 'slug';
  static const String productDescription = 'description';
  static const String productImages = 'images';
  static const String productCategoryId = 'categoryId';
  static const String productPrice = 'price';
  static const String productComparePrice = 'comparePrice';
  static const String productSku = 'sku';
  static const String productStock = 'stock';
  static const String productIsFeatured = 'isFeatured';
  static const String productIsNewArrival = 'isNewArrival';
  static const String productIsBestSeller = 'isBestSeller';
  static const String productIsAvailable = 'isAvailable';
  static const String productTags = 'tags';
  static const String productBenefits = 'benefits';
  static const String productIngredients = 'ingredients';
  static const String productHowToUse = 'howToUse';
  static const String productWeight = 'weight';
  static const String productRating = 'rating';
  static const String productReviewCount = 'reviewCount';
  static const String productSoldCount = 'soldCount';

  // Order Fields
  static const String orderNumber = 'orderNumber';
  static const String orderUserId = 'userId';
  static const String orderStatus = 'status';
  static const String orderItems2 = 'items';
  static const String orderSubtotal = 'subtotal';
  static const String orderShippingFee = 'shippingFee';
  static const String orderDiscount = 'discount';
  static const String orderTotal = 'total';
  static const String orderCouponCode = 'couponCode';
  static const String orderAddressId = 'addressId';
  static const String orderPaymentId = 'paymentId';
  static const String orderTrackingNumber = 'trackingNumber';
  static const String orderCourierName = 'courierName';
  static const String orderNotes = 'notes';

  // Payment Fields
  static const String paymentOrderId = 'orderId';
  static const String paymentUserId = 'userId';
  static const String paymentGateway = 'gateway';
  static const String paymentReference = 'reference';
  static const String paymentStatus = 'status';
  static const String paymentAmount = 'amount';
  static const String paymentCurrency = 'currency';
  static const String paymentVerified = 'verified';
  static const String paymentMetadata = 'metadata';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleCustomer = 'customer';
  static const String roleGuest = 'guest';

  // Order Status Values
  static const String orderPending = 'pending_payment';
  static const String orderPaid = 'paid';
  static const String orderConfirmed = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderPacked = 'packed';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderRefunded = 'refunded';

  // Payment Status Values
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Settings Keys
  static const String settingsShipping = 'shipping';
  static const String settingsApp = 'app';
  static const String settingsPayment = 'payment';

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchPageSize = 15;
  static const int adminPageSize = 25;
}
