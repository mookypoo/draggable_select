import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Main());
  }
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("제임스 쌤 따라하기"), centerTitle: true,),
      body: DraggableSelectWidget(
        columnCount: 20,
        rowCount: 7,
        titles: ["월", "화", "수", "목", "금", "토", "일"],
        onSelected: (List<List<bool>> matrix) {
          print(matrix);
        },
      ),
    );
  }
}

class DraggableSelectWidget extends StatefulWidget {
  DraggableSelectWidget({Key? key, required this.columnCount, required this.rowCount, required this.titles, required this.onSelected}) : super(key: key);
  final int rowCount; // x
  final int columnCount; // y
  final List<String> titles;
  final void Function(List<List<bool>>) onSelected;

  @override
  State<DraggableSelectWidget> createState() => _DraggableSelectWidgetState();
}

class _DraggableSelectWidgetState extends State<DraggableSelectWidget> {
  final double _height = 34.0;
  List<List<bool>> matrix = [];

  @override
  void initState() {
    super.initState();
    this.matrix = List<List<bool>>.generate(
      this.widget.rowCount,
      (int index) => List<bool>.generate(this.widget.columnCount, (int index) => false));
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return SizedBox(
      width: _size.width,
      child: Column(
        children: <Widget>[
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: this.widget.titles.map((String s) => SizedBox(
               width: _size.width / this.widget.rowCount,
               child: Text(s, style: const TextStyle(fontSize: 16.0), textAlign: TextAlign.center,),
             )).toList()
           ),
           Expanded(
             child: Row(
               children: List<Widget>.generate(this.widget.rowCount, (int x) {
                 return Column(
                   children: List<Widget>.generate(this.widget.columnCount, (int y) {
                     bool _isSelected = false;
                     if (this.matrix[x][y]) _isSelected = true;
                     return DragItem(
                       matrix: this.matrix,
                       height: this._height,
                       isSelected: _isSelected,
                       x: x, y: y,
                       width: _size.width / this.widget.rowCount,
                       setState: (void Function() setState) => this.setState(() => setState()),
                     );
                   }),
                 );
               }).toList(),
             ),
           )
        ],
      ),
    );
  }
}

class DragItem extends StatefulWidget {
  const DragItem({Key? key, required this.matrix, required this.x, required this.y, required this.width, required this.isSelected, required this.height, required this.setState}) : super(key: key);
  final int x;
  final int y;
  final double width;
  final bool isSelected;
  final double height;
  final List<List<bool>> matrix;
  final void Function(void Function()) setState;

  @override
  State<DragItem> createState() => _DragItemState();
}

class _DragItemState extends State<DragItem> {
  int _xMax = 0;
  int _xMin = 0;
  int _xAxisMove = 0;
  int _yAxisMove = 0;
  int _yMax = 0;
  int _yMin = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onPanStart: (DragStartDetails data) {
        print("start: (${this.widget.x}, ${this.widget.y})");
        this.widget.setState(() {
          this.widget.matrix[this.widget.x][this.widget.y] = true;
        });
      },
      onPanUpdate: (DragUpdateDetails data) {
        // going left, next one becomes 0, -30
        // going rightt, next one becomes 30, 60
        int i = data.localPosition.dx ~/ this.widget.width;
        if (data.localPosition.dx.isNegative) i -= 1;
        int j = data.localPosition.dy ~/ this.widget.height;
        if (data.localPosition.dy.isNegative) j -= 1;
        if (this._xAxisMove != i) {
          print("x asxis move");
          this._xAxisMove = i;
          if (i > this._xMax) this._xMax = i;
          if (i < this._xMin) this._xMin = i;
          this.widget.matrix[this.widget.x+i][this.widget.y] = true;
          for (int a = this._yMin; a <= -1; a++) {
            this.widget.matrix[this.widget.x+i][this.widget.y+a] = true;
          }
          for (int a = 1; a <= this._yMax; a++) {
            this.widget.matrix[this.widget.x+i][this.widget.y+a] = true;
          }
          this.widget.setState(() {});
        }
        if (this._yAxisMove != j) {
          print("y axis move");
          this._yAxisMove = j;
          if (j > this._yMax) this._yMax = j;
          if (j < this._yMin) this._yMin = j;
          this.widget.matrix[this.widget.x][this.widget.y+j] = true;
          for (int a = this._xMin; a <= -1; a++) {
            this.widget.matrix[this.widget.x+a][this.widget.y+j] = true;
          }
          for (int a = 1; a <= this._xMax; a++) {
            this.widget.matrix[this.widget.x+a][this.widget.y+j] = true;
          }
          this.widget.setState(() {});
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: this.widget.width,
        height: this.widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          color: this.widget.isSelected ? Colors.red : Colors.white
        ),
        child: Text("(${this.widget.x}, ${this.widget.y})", style: const TextStyle(fontSize: 16.0),),
      ),
    );
  }
}
