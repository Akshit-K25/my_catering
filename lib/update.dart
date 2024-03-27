import 'package:flutter/material.dart';
import 'mongodb.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late List<Map<String, dynamic>> items = [];
  late final List<TextEditingController> _updateControllers;

  @override
  void initState() {
    super.initState();
    _updateControllers = [];
    fetchDataAndUpdateData();
  }

  Future<void> fetchDataAndUpdateData() async {
    final List<Map<String, dynamic>> fetchedItems = await MongoDB().fetchFeedData();
    setState(() {
      items = fetchedItems;
      _updateControllers.clear();
      for (int i = 0; i < items.length; i++) {
        _updateControllers.add(TextEditingController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a list to store DataRow widgets
    List<DataRow> _dataRows = List.generate(items.length, (index) {
      return DataRow(
        cells: [
          DataCell(SizedBox(width: 100, child: Text(items[index]['itemName'].toString(), style: TextStyle(fontSize: 12, color: Colors.black)))),
          DataCell(SizedBox(width: 100, child: Text(items[index]['itemStock'].toString(), style: TextStyle(fontSize: 12, color: Colors.black)))),
          DataCell(Container(
            width: 100,
            decoration: BoxDecoration(
              color: Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: TextField(
              controller: _updateControllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Qty',
                border: InputBorder.none,
              ),
            ),
          )),
        ],
      );
    });

    return Scaffold(
      backgroundColor: Color(0xFF1D0E58),
      appBar: AppBar(
        backgroundColor: Color(0xFFE1E1E5),
        title: Text(
          'Update',
          style: TextStyle(color: Color(0xFF1D0E58)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1D0E58)),
      ),
      drawer: Sidebar(),
      body: Container(
        color: Color(0xFF1D0E58),
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xFF1D0E58),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: DataTable(
                  columnSpacing: 5, // Decrease column spacing
                  columns: [
                    DataColumn(label: Text('Item Name', style: TextStyle(fontSize: 14, color: Color(0xFF1D0E58), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Item Stock', style: TextStyle(fontSize: 14, color: Color(0xFF1D0E58), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Update Stock', style: TextStyle(fontSize: 14, color: Color(0xFF1D0E58), fontWeight: FontWeight.bold))),
                  ],
                  rows: _dataRows,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE1E1E5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () async {
              updateItemStock();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('Selected items updated successfully'),
                    actions: [
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1D0E58),
              padding: EdgeInsets.symmetric(vertical: 12),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text('Update', style: TextStyle(color: Color(0xFFE1E1E5))),
          ),
        ),
      ),
    );
  }

  void updateItemStock() {
    for (int i = 0; i < items.length; i++) {
      int updateQuantity = int.tryParse(_updateControllers[i].text) ?? 0;
      if (updateQuantity > 0) {
        setState(() {
          items[i]['itemStock'] += updateQuantity;
          items[i]['initialStock'] += updateQuantity;
          _updateControllers[i].clear();
        });
        MongoDB().updateItemStock(items[i]['itemName'], items[i]['itemStock'], items[i]['initialStock']);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _updateControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF1D0E58),
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
                  SizedBox(height: 5),
                  Text(
                    'C.R.C.L',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Consolas',
                    ),
                  ),
                  SizedBox(height: 20),
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
    );
  }
}