
import 'package:flutter/material.dart';
import 'package:todoapp/utils/date_formatter.dart';
import '../models/todo_item.dart';
import '../utils/database_client.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {

  TextEditingController _textEditingController = new TextEditingController();
  TextEditingController _updatedTextEditingController = new TextEditingController();

  var db = new DatabaseHelper();
  final List<ToDoItem> _itemList = <ToDoItem>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readToDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();

    ToDoItem toDoItem = new ToDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(toDoItem);

    ToDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("Item saved id: ${savedItemId.toString()}");

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index){
                    return new Card(
                      color: Colors.white10,
                      child: new ListTile(
                        title: _itemList[index],

                        onLongPress: (){
                          _updateToDo(_itemList[index], index);
                        },

                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle,
                              color: Colors.redAccent,),
                          onPointerDown: (pointerEvent){
                            _deleteToDo(_itemList[index].id, index);
                          },
                        ),
                      ),
                    );
                  }
              )
          ),

          new Divider(height: 1.0,),
        ],
      ),


      floatingActionButton: new FloatingActionButton(
          tooltip: "Add item",
          backgroundColor: Colors.greenAccent,
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
          onPressed: _showFormedDialog,
      ),
    );
  }

  void _showFormedDialog() {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "e.g Don't buy stuff",
                  icon: new Icon(Icons.note_add)
                ),
              )
          ),
        ],
      ),

      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: new Text("Save"),
        ),

        new FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: new Text("Cancel")
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (context){
          return alert;
        }
    );
  }

  //  items or item--> if error please check
  _readToDoList() async {
    List items = await db.getItems();
    items.forEach((item){
//      ToDoItem toDoItem = ToDoItem.map(item);
      
      setState(() {
        _itemList.add(ToDoItem.map(item));
      });
      
//      print("Db items: ${toDoItem.itemName}");
    });
  }

  void _deleteToDo(int id, int index) async{
    debugPrint("deleted item. id no:: $id");

    await db.deleteItem(id);

    setState(() {
      _itemList.removeAt(index);
    });
  }

  void _updateToDo(ToDoItem item, int index) {
    var alert = new AlertDialog(
      title: new Text("Update ToDo"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _updatedTextEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg. dont buy stuff",
                  icon: new Icon(Icons.update)
                ),
              ),
          ),
        ],
      ),
      
      actions: <Widget>[
        new FlatButton(
            onPressed: () async{
              ToDoItem newItemUpdated = ToDoItem.fromMap({
                //  passing a map
                "itemName": _updatedTextEditingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id
              });

              /** redrawing the screen **/
              _handleSubmittedUpdate(index, item);  //  redraw the screen/item
              await db.updateItem(newItemUpdated);  //  updating the item

              setState(() {
                //  redrawing the screen with all the items in the screen
                _readToDoList();
              });

              Navigator.pop(context);
              _updatedTextEditingController.clear();
            },
            child: new Text("Update")
        ),

        new FlatButton(
            onPressed: ()=>Navigator.pop(context),
            child: new Text("Cancel"),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context){
        return alert;
      }
    );
  }

  //  called that moment when we hit the update
  void _handleSubmittedUpdate(int index, ToDoItem item) {
    setState(() {
      _itemList.removeWhere((element){
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
