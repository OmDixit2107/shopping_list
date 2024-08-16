import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryitems = [];
  var isloading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = Uri.https(
        'flutter-prep-b2354-default-rtdb.europe-west1.firebasedatabase.app',
        'shopping-list.json');
    final response = await http.get(url);
    if (response.body=="null") {
      setState(() {
        isloading=false;
      });
      return;
    }
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> _loadeditems = [];
    for (final item in listdata.entries) {
      final categ = categories.entries
          .firstWhere(
              (catitem) => catitem.value.categories == item.value['category'])
          .value;
      _loadeditems.add(
        GroceryItem(
          category: categ,
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
        ),
      );
    }
    setState(() {
      _groceryitems = _loadeditems;
      isloading = false;
    });
  }

  void _additem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newitem == null) {
      return;
    }
    setState(() {
      _groceryitems.add(newitem);
    });
  }

  void _removeitem(GroceryItem item) {
    final url = Uri.https(
          'flutter-prep-b2354-default-rtdb.europe-west1.firebasedatabase.app',
          'shopping-list/${item.id}.json');
    http.delete(url);
    setState(() {
      _groceryitems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No content added yet"),
    );
    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitems.length,
        itemBuilder: (ctx, idx) => Dismissible(
          onDismissed: (direction) {
            _removeitem(
              _groceryitems[idx],
            );
          },
          key: ValueKey(_groceryitems[idx].id),
          child: ListTile(
            title: Text(_groceryitems[idx].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryitems[idx].category.color,
            ),
            trailing: Text(
              _groceryitems[idx].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
              onPressed: _additem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: content);
  }
}
