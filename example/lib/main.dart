import 'package:flutter/material.dart';
import 'package:typeaheadx/typeaheadx.dart';

void main() {
  runApp(const TypeAheadXExampleApp());
}

class TypeAheadXExampleApp extends StatelessWidget {
  const TypeAheadXExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TypeAheadX Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TypeAheadXDemoPage(),
    );
  }
}

class TypeAheadXDemoPage extends StatefulWidget {
  const TypeAheadXDemoPage({super.key});

  @override
  State<TypeAheadXDemoPage> createState() => _TypeAheadXDemoPageState();
}

class _TypeAheadXDemoPageState extends State<TypeAheadXDemoPage> {
  final List<String> _allItems = [
    // Page 1: 10 items (Indices 0-9)
    'Result 1: The Quick Brown Fox',
    'Result 2: Jumps Over The',
    'Result 3: Lazy Dog And The',
    'Result 4: Fifth Duckling, Which',
    'Result 5: Swims Calmly Across',
    'Result 6: The Blue Lake With',
    'Result 7: Its Mother And Two',
    'Result 8: Other Siblings, Ignoring',
    'Result 9: The Bright Sun, And',
    'Result 10: Finds A Small Fish.', // End of Page 1

    // Page 2: 8 items (Indices 10-17)
    'Result 11: Meanwhile, Back On The Shore,',
    'Result 12: A Squirrel Buries Its Nuts,',
    'Result 13: Preparing For The Upcoming Winter,',
    'Result 14: Which Promises To Be Cold,',
    'Result 15: But Also Quite Snowy And Fun,',
    'Result 16: Provided The Bird Feeder Is Full,',
    'Result 17: And The Fireplace Is Already Set,',
    'Result 18: Ready For A Cozy Evening.', // End of Page 2 (Total 18 items)

    'Result 1: The Quick Brown Fox',
    'Result 2: Jumps Over The',
    'Result 3: Lazy Dog And The',
    'Result 4: Fifth Duckling, Which',
    'Result 5: Swims Calmly Across',
    'Result 6: The Blue Lake With',
    'Result 7: Its Mother And Two',
    'Result 8: Other Siblings, Ignoring',
    'Result 9: The Bright Sun, And',
    'Result 10: Finds A Small Fish.', // End of Page 1
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TypeAheadX Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: TypeAheadX(
                onChanged: (value) {

                },
                itemList: [],
                hintText: "Type # & Select",
                pagination: true,
                style: TypeAheadXStyle(
                ),
                // fetchSuggestions: (d) async {
                //   return await getvalue("", 1, 10);
                // },
                pageSize: 10,
                enabled: true,
                onValueChanged: (value) {
                  debugPrint(value);
                },
                onSubmitted: (value) {
                  debugPrint(value);
                },
                fetchPaginated: (value, page, pageSize) async {
                  return await getvalue(value, page, pageSize);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<List<String>> getvalue(String value, int page, int pageSize) async {
    debugPrint("API - CALL");
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // The 'value' and 'pageSize' parameters are ignored for this fixed, fake pagination.
    if (page == 1) {
      // Return the first 10 items (indices 0 to 9).
      // The second argument (10) is the exclusive end index.
      return _allItems.sublist(0, 10);
    } else if (page == 2) {
      // Return the next 8 items (indices 10 to 17).
      // The second argument (18) is the exclusive end index.
      return _allItems.sublist(10, 20);
    }else if (page == 3) {
      debugPrint("fjfjfj ");
      // Return the next 8 items (indices 10 to 17).
      // The second argument (18) is the exclusive end index.
      return _allItems.sublist(20, 25);
    } else {
      // Page is out of bounds for the 2-page system
      return [];
    }
  }
}