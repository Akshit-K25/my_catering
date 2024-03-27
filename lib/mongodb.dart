import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  late Db _db;
  bool _isConnected = false;

  MongoDB() {
    _connect(); // Call the connect method when MongoDB is instantiated
  }

  Future<void> _connect() async {
    final String uri = 'mongodb+srv://akshitk2518:akshitk1927@cluster0.ruiyppc.mongodb.net/?retryWrites=true&w=majority/test';
    _db = await Db.create(uri);
    await _db.open();
  }

  Future<void> createFeedItem(String itemName, double itemPrice, int itemStock) async {
    final Map<String, dynamic> feedItem = {
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemStock': itemStock,
      'initialStock': itemStock,
    };
    await _db.collection('feed').insert(feedItem);
  }

  Future<void> clearFeedCollection() async {
    await _db.collection('feed').remove({});
  }

  Future<List<Map<String, dynamic>>> fetchFeedData() async {
    await _connect(); // Ensure that the connection is established before fetching data
    final collection = _db.collection('feed');
    final items = await collection.find().toList();
    return items;
  }

  Future<void> updateItemStock(String itemName, int newStock, int newInitialStock) async {
    if (!_isConnected) {
      await _connect(); // Ensure that the connection is established before updating item stock
    }

    // Update all items with the given itemName
    await _db.collection('feed').update(
      where.eq('itemName', itemName),
      modify
          .set('itemStock', newStock)
          .set('initialStock', newInitialStock), // Update both itemStock and initialStock
      multiUpdate: true, // Ensure that all matching documents are updated
    );
  }
}

class OrdersRepository {
  late Db _db;
  bool _isDbInitialized = false;

  OrdersRepository() {
    _connect();
  }

  Future<void> _connect() async {
    final String uri =
        'mongodb+srv://akshitk2518:akshitk1927@cluster0.ruiyppc.mongodb.net/?retryWrites=true&w=majority/test';
    _db = await Db.create(uri);
    await _db.open();
    _isDbInitialized = true;
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    while (!_isDbInitialized) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    final ordersCollection = _db.collection('orders');
    final orders = await ordersCollection.find().toList();

    List<Map<String, dynamic>> formattedOrders = [];
    for (var order in orders) {
      formattedOrders.add({
        'token': order['token'],
        'email': order['email'],
        'quantities': order['quantities'],
        'totalAmount': order['totalAmount'],
        'status': order['status'] ?? false,
      });
    }
    return formattedOrders;
  }

  Future<void> clearOrders() async {
    final ordersCollection = _db.collection('orders');
    await ordersCollection.remove({});
  }

  Future<void> updateOrderStatus(String token, bool newStatus) async {
    await _db.collection('orders').update(
      where.eq('token', token),
      modify.set('status', newStatus),
    );
  }
}