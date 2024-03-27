import 'package:flutter/material.dart';
import 'mongodb.dart';
import 'orders.dart';
import 'update.dart';
import 'analyze.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orders App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrderPage(),
      routes: {
        '/feeds': (context) => OrderPage(),
        '/orders': (context) => OrdersPage(),
        '/update': (context) => UpdatePage(),
        '/analyze': (context) => AnalyzePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class OrderItem {
  String itemName;
  double itemPrice;
  int itemStock;

  OrderItem({required this.itemName, required this.itemPrice, required this.itemStock});
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int orderCount = 0;
  List<OrderItem> orderItems = [];
  final MongoDB mongoDB = MongoDB();

  void generateOrderItems(int count) {
    orderItems.clear();
    for (int i = 1; i <= count; i++) {
      orderItems.add(
          OrderItem(itemName: '', itemPrice: 0.0, itemStock: 0));
    }
  }

  Future<void> submitOrders() async {
    for (OrderItem item in orderItems) {
      if (item.itemPrice <= 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please enter item price for ${item.itemName}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      await mongoDB.createFeedItem(
          item.itemName, item.itemPrice, item.itemStock);
    }

    orderItems.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Submitted Successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> clearFeed() async {
    await mongoDB.clearFeedCollection();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feed Cleared Successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF1D0E58),
        title: Text(
            'Feeds',
            style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF1D0E58), // Set the background color of the Drawer
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/App_Icon.jpg',
                      width: 136,
                      height: 136,
                    ),
                    SizedBox(height: 5), // Reduce the height here
                    Text(
                      'C.R.C.L',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Consolas',
                      ),
                    ),
                    SizedBox(height: 20), // Add space between text and list tiles
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Feeds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushReplacementNamed(context, '/feeds');
                      },
                    ),
                    ListTile(
                      title: Text('Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushReplacementNamed(context, '/orders');
                      },
                    ),
                    ListTile(
                      title: Text('Update', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushReplacementNamed(context, '/update');
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 250), // Add margin to the bottom of the last list tile
                      child: ListTile(
                        title: Text('Analyze', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.pushReplacementNamed(context, '/analyze');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  'By Cravy Nights',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hello C.R.C.L',
                style: TextStyle(fontSize: 25, color: Color(0xFF1D0E58), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              Text(
                'How many orders today?',
                style: TextStyle(fontSize: 18.0, color: Color(0xFF1D0E58), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15.0),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // Adjust vertical offset to control shadow position
                    ),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      orderCount = int.tryParse(value) ?? 0;
                      generateOrderItems(orderCount);
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
                    border: InputBorder.none,
                    hintText: 'Enter order count',
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Column(
                children: [
                  for (int i = 0; i < orderItems.length; i += 2)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: OrderFields(orderItem: orderItems[i], orderIndex: i)),
                            SizedBox(width: 10.0),
                            if (i + 1 < orderItems.length)
                              Expanded(child: OrderFields(orderItem: orderItems[i + 1], orderIndex: i + 1)),
                          ],
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  if (orderItems.isNotEmpty) SizedBox(height: 20.0),
                  if (orderItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitOrders,
                        child: Text('Submit', style: TextStyle(color: Color(0xFFE1E1E5))),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1D0E58))),
                      ),
                    ),
                  SizedBox(height: 15.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: clearFeed,
                      child: Text('Clear Feed', style: TextStyle(color: Color(0xFFE1E1E5))),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1D0E58))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFE1E1E5),
    );
  }
}

class OrderFields extends StatefulWidget {
  final OrderItem orderItem;
  final int orderIndex;

  const OrderFields({Key? key, required this.orderItem, required this.orderIndex}) : super(key: key);

  @override
  _OrderFieldsState createState() => _OrderFieldsState();
}

class _OrderFieldsState extends State<OrderFields> {
  late TextEditingController itemNameController;
  late TextEditingController itemPriceController;
  late TextEditingController itemStockController;

  @override
  void initState() {
    super.initState();
    itemNameController = TextEditingController(text: widget.orderItem.itemName);
    itemPriceController = TextEditingController();
    itemStockController = TextEditingController();
  }

  @override
  void dispose() {
    itemNameController.dispose();
    itemPriceController.dispose();
    itemStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ${widget.orderIndex + 1}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              'Item Name:',
              style: TextStyle(fontSize: 16.0),
            ),
            TextField(
              controller: itemNameController,
              onChanged: (value) {
                setState(() {
                  widget.orderItem.itemName = value;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Item Name',
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Item Price:',
              style: TextStyle(fontSize: 16.0),
            ),
            TextFormField(
              controller: itemPriceController,
              onChanged: (value) {
                setState(() {
                  widget.orderItem.itemPrice = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter item price',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid price';
                }
                final double? price = double.tryParse(value);
                if (price == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 10.0),
            Text(
              'Item Stock:',
              style: TextStyle(fontSize: 16.0),
            ),
            TextField(
              controller: itemStockController,
              onChanged: (value) {
                setState(() {
                  widget.orderItem.itemStock = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter item stock',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}