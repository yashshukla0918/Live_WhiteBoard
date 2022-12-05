import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WhiteBoards extends StatefulWidget {
  const WhiteBoards({Key? key}) : super(key: key);

  @override
  State<WhiteBoards> createState() => _WhiteBoardsState();
}

class _WhiteBoardsState extends State<WhiteBoards> {
  List<DrawingPoint> drawingPoints = [];
   bool erase = false;
  DatabaseReference ref = FirebaseDatabase.instance.ref("mytest");

  late Stream<DatabaseEvent> stream = ref.onValue;


  @override
  void initState() {
    stream.listen((event) {
      var valuess = jsonDecode(event.snapshot.value.toString()) ;
      num x=valuess[0];
      num y =valuess[1];
      setState(() {
        drawingPoints.add(
          DrawingPoint(
            Offset(x.toDouble(), y.toDouble()),
            Paint()
              ..color = Colors.black
              ..isAntiAlias = true
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round
              ..blendMode = erase ? BlendMode.clear : BlendMode.srcOver,
          )
        );
      });
    });
    super.initState();
  }


  @override
  void dispose() {
    initState();
    super.dispose();
  }
  @override

  Widget build(BuildContext context) {
     Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("mytest").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if(snapshot.hasData){
              return RotatedBox(
                quarterTurns: 1,
                child: CustomPaint(
                  size:Size(1367, 667), //Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  painter: _DrawingPainter(drawingPoints),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: size.height,
                        width: size.width,
                      ),
                    )
                ),
              );
            }
            else if(snapshot.hasError){
              return Center(
                child: Text("Error : ${snapshot.error}"),
              );
            }
            else{

              return const Center(
                child: Text('No Data Found'),
              );
            }
          },
        ),
      ),
    );
  }
}
class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;


  _DrawingPainter(this.drawingPoints);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {


    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i].offset.dx != -1 &&
          drawingPoints[i + 1].offset.dx != -1) {
        canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
            drawingPoints[i].paint);
      } else if (drawingPoints[i].offset.dx != -1 &&
          drawingPoints[i + 1].offset.dx == -1) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i].offset);

        canvas.drawPoints(PointMode.points, offsetsList, drawingPoints[i].paint);
      }

    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}

