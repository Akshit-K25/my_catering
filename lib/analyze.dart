import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'mongodb.dart';
import 'orders.dart';
import 'update.dart';

class AnalyzePage extends StatefulWidget {
  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final MongoDB mongoDB = MongoDB();
  List<Map<String, dynamic>> data = [];
  bool isAnalyzed = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> fetchedData = await mongoDB.fetchFeedData();
    setState(() {
      data = fetchedData.map((item) {
        int initialStock = item['initialStock'] ?? 0;
        int itemStock = item['itemStock'] ?? 0;
        return {
          'itemName': item['itemName'],
          'totalStocks': initialStock,
          'sold': initialStock - itemStock,
        };
      }).toList();
      isLoading = false;
      isAnalyzed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE1E1E5),
        title: Text(
          'Analyze',
          style: TextStyle(color: Color(0xFF1D0E58)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1D0E58)),
      ),
      drawer: Drawer(
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
                      padding: EdgeInsets.only(bottom: 250),
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
      body: Stack(
        children: [
          Container(
            color: Color(0xFF1D0E58),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isAnalyzed) ...[
                    SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0, top: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9), // Background color of the table
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: DataTable(
                              dataRowColor: MaterialStateColor.resolveWith((states) => Color(0xFFD9D9D9)), // Background color of the rows
                              headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFFD9D9D9)), // Background color of the heading row
                              columns: [
                                DataColumn(label: Text('Item Name', style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the column headers
                                DataColumn(label: Text('Total Stocks', style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the column headers
                                DataColumn(label: Text('Sold', style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the column headers
                              ],
                              rows: List<DataRow>.generate(
                                data.length,
                                    (index) => DataRow(
                                  cells: [
                                    DataCell(Text(data[index]['itemName'].toString(), style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the cells
                                    DataCell(Text(data[index]['totalStocks'].toString(), style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the cells
                                    DataCell(Text(data[index]['sold'].toString(), style: TextStyle(color: Color(0xFF1D0E58)))), // Text color of the cells
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE1E1E5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () => fetchData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1D0E58),
              ),
              child: Text('Analyze', style: TextStyle(color: Color(0xFFE1E1E5))),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}