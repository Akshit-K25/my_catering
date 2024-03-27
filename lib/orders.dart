import 'package:flutter/material.dart';
import 'mongodb.dart';
import 'feed.dart';
import 'update.dart';
import 'analyze.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrdersRepository _ordersRepository = OrdersRepository();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  Map<int, bool> _iconStates = {}; // Track long press states for icons

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await _ordersRepository.fetchOrders();
      setState(() {
        _orders = orders.map((order) => {...order, 'clicked': false}).toList();
        _loading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _clearOrders() async {
    try {
      await _ordersRepository.clearOrders();
      setState(() {
        _orders.clear();
      });
    } catch (e) {
      print('Error clearing orders: $e');
    }
  }

  Future<void> _updateOrderStatus(String token, bool newStatus) async {
    try {
      await _ordersRepository.updateOrderStatus(token, newStatus);
      // Update local orders list with the new status
      setState(() {
        _orders = _orders.map((order) {
          if (order['token'] == token) {
            return {...order, 'status': newStatus};
          }
          return order;
        }).toList();
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        title: Text(
            'Orders',
          style: TextStyle(color: Color(0xFF1D0E58)),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF1D0E58)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
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
      body: Container(
        color: Color(0xFF1D0E58),
        child: _loading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
          ),
        )
            : ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            _iconStates[index] ??= false; // Initialize state
            return GestureDetector(
              onTap: () {
                setState(() {
                  _orders[index]['clicked'] = !_orders[index]['clicked'];
                  _iconStates[index] = _orders[index]['clicked'];
                });
              },
              onLongPress: () {
                setState(() {
                  if (_iconStates[index] == true) {
                    _iconStates[index] = false;
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                            'Token: ${order['token']}',
                          style: TextStyle(color: Color(0xFF1D0E58), fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Email: ${order['email']}',
                              style: TextStyle(color: Color(0xFF1D0E58), fontSize: 16),
                            ),
                            Text(
                                'Quantities: ${order['quantities']}',
                              style: TextStyle(color: Color(0xFF1D0E58), fontSize: 16),
                            ),
                            Text(
                                'Total Amount: ${order['totalAmount']}',
                              style: TextStyle(color: Color(0xFF1D0E58), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                size: 50,
                                color: (order['status'] ?? false) ? Color(0xFF078F1D) : Colors.grey,
                              ),
                              onPressed: () {
                                if (!(order['status'] ?? false)) { // Only allow update if status is false
                                  _updateOrderStatus(order['token'], true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE1E1E5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: _clearOrders,
                  child: Text(
                    'Clear Orders',
                    style: TextStyle(color: Color(0xFFE1E1E5)),
                  ),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1D0E58))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrdersPage(),
    routes: {
      '/feeds': (context) => OrderPage(),
      '/orders': (context) => OrdersPage(),
      '/update': (context) => UpdatePage(),
      '/analyze': (context) => AnalyzePage(),
    },
    debugShowCheckedModeBanner: false,
  ));
}