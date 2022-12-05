import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screen_recorder/screen_recorder.dart';


class PenScreen extends StatefulWidget {
  const PenScreen({Key? key, required this.broadCasting}) : super(key: key);
  final bool broadCasting;
  @override
  State<PenScreen> createState() => _PenScreenState();
}

class _PenScreenState extends State<PenScreen> {
  Color selectedColor = Colors.blue;
  double strokeWidth = 5;
  bool erase = false;
  List<DrawingPoint> drawingPoints = [];
  List<Color> colors = [
    Colors.teal,
    Colors.red,
    Colors.blue,
    Colors.white,
    Colors.amberAccent,
    Colors.purple,
    Colors.green,
  ];
  final DatabaseReference _testRef = FirebaseDatabase.instance.ref().child("mytest");
  //List<DrawingPoint>? stoppingPoint = null;

  ScreenRecorderController controller =ScreenRecorderController(
    skipFramesBetweenCaptures: -5,
  );
  final ImagePicker videoMaker = ImagePicker();
  Future<void> saverecording() async {
    var gif = await controller.export();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.memory(Uint8List.fromList(gif!)),
        );
      },
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  void hideStatusBar() {
    setState(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    });
  }

  @override
  void dispose() {
    controller;
    saverecording();
   hideStatusBar();
    super.dispose();
  }

  List<IconData> arrowIcon = [Icons.arrow_forward_ios, Icons.arrow_back_ios];
  int isArrowButtonClicked = 1;
  int isEditButtonClicked = 1;
  int isColorButtonClicked = 1;
  int colorNumber = 2;
  bool isRecording = false;
  void selectColor(int num) {
    setState(() {
      colorNumber = num;
      selectedColor = colors[num];
    });
  }


  void resetSideNav(){
    if (isArrowButtonClicked == 0) {
      setState(() {
        isArrowButtonClicked = 1;
        isEditButtonClicked = 1;
        isColorButtonClicked = 1;
        erase =false;
      });
    } else {
      setState(() {
        isArrowButtonClicked = 0;
        isColorButtonClicked=0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //print(size);
    return SafeArea(
        child: Stack(
      children: [
        GestureDetector(
         onLongPress: (){
           hideStatusBar();
         },
          onPanStart: (details) {
            var data=[details.localPosition.dx,details.localPosition.dy];
            widget.broadCasting? _testRef.set(data.toString()).asStream():null;
            setState(() {
              drawingPoints.add(
                DrawingPoint(
                  details.localPosition,
                  Paint()
                    ..color = selectedColor
                    ..isAntiAlias = true
                    ..strokeWidth = strokeWidth
                    ..strokeCap = StrokeCap.round
                    ..blendMode = erase ? BlendMode.clear : BlendMode.srcOver,
                ),
              );
            });
          },
          onPanUpdate: (details) {
            var data=[details.localPosition.dx,details.localPosition.dy];
            widget.broadCasting?_testRef.set(data.toString()).asStream():null;      //(details.localPosition.toString());
            setState(() {
              //print(details.localPosition);
              drawingPoints.add(
                DrawingPoint(
                  details.localPosition,
                  Paint()
                    ..color = selectedColor
                    ..isAntiAlias = true
                    ..strokeWidth = strokeWidth
                    ..strokeCap = StrokeCap.round
                    ..blendMode = erase ? BlendMode.clear : BlendMode.srcOver,
                ),
              );
            });
          },
          onPanEnd: (details) {
            // print(details.localPosition);
            widget.broadCasting?_testRef.set('[-1,-1]'):null;
            setState(() {
              drawingPoints.add(DrawingPoint(const Offset(-1, -1), Paint()));
            });
          },

          child: ScreenRecorder(
            width: size.width,
            height: size.height,
            background: Colors.black,
            controller: controller,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
              painter: _DrawingPainter(drawingPoints),
              child: SizedBox(
                height:size.height,
                width: size.width,
              ),
            ),
          ) ,
        ),
        Stack(
          alignment: Alignment.centerRight,
          fit: StackFit.passthrough,
          children: [

            //isColorButtonClicked.isEven
            //Color Picker Widget
            isColorButtonClicked.isEven? Positioned(
                    right: size.width * 0.2,
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: Card(
                        color: Colors.white70,
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              ColorButton(
                                  color: colors[6],
                                  sfunction: () {
                                    selectColor(6);
                                  }),
                              ColorButton(
                                  color: colors[5],
                                  sfunction: () {
                                    selectColor(5);
                                  }),
                              ColorButton(
                                  color: colors[4],
                                  sfunction: () {
                                    selectColor(4);
                                  }),
                              ColorButton(
                                  color: colors[3],
                                  sfunction: () {
                                    selectColor(3);
                                  }),
                              ColorButton(
                                  color: colors[2],
                                  sfunction: () {
                                    selectColor(2);
                                  }),
                              ColorButton(
                                  color: colors[1],
                                  sfunction: () {
                                    selectColor(1);
                                  }),
                              ColorButton(
                                  color: colors[0],
                                  sfunction: () {
                                    selectColor(0);
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
            isEditButtonClicked.isEven ? Positioned(
                    right: size.width * 0.5,
                    child: Icon(
                      Icons.circle,
                      color: colors[colorNumber],
                      size: (strokeWidth*0.25)+strokeWidth,
                    )) : Container(),

            //Pen Point Size Slider
            isEditButtonClicked.isEven ? Positioned(
                    right: size.width * 0.2,
                    child: SizedBox(
                      height: size.height * 0.6,
                      width: 100,
                      child: Card(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Slider(
                              thumbColor: Colors.black,
                              activeColor: Colors.red,
                              inactiveColor: Colors.black12,
                              min: 0,
                              max:50,
                              value: strokeWidth,
                              onChanged: (value) {
                                setState(() {
                                  strokeWidth = value;
                                });
                              }),
                        ),
                      ),
                    ),
                  ) : Container(),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10.0)),
              width: size.width * 0.15,
              height: isArrowButtonClicked.isEven
                  ? size.height * 0.5
                  : size.height * 0.1,
              child: Column(
                mainAxisAlignment: isArrowButtonClicked.isEven
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  //Arrow button
                  GestureDetector(
                      onTap: () {
                        resetSideNav();
                      },
                      child: Icon(arrowIcon[isArrowButtonClicked])),
                  if (isArrowButtonClicked.isEven) ...[
                    //Erase All Button
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          if(isRecording){
                            isRecording = false;
                            controller.stop();
                            saverecording();
                          }
                          else{
                            isRecording = true;
                            controller.start();
                          }
                        });
                      },
                      child:  Icon(Icons.camera_alt,color: isRecording ?Colors.red:Colors.black,),
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            drawingPoints.clear();
                          });
                        }, child: const Icon(Icons.delete)),
                    //Eraser Button
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            if(erase){
                              erase =false;
                            }
                            else{
                              erase = true;
                            }
                          });
                        }, child: const Icon(Icons.eco_sharp)),
                    //Color Picker Button
                    Icon(
                      Icons.circle,
                      color: colors[colorNumber],
                    ),
                    //Edit Button
                    GestureDetector(
                        onTap: () {
                          if (isEditButtonClicked == 0) {
                            setState(() {
                              isEditButtonClicked = 1;
                              isColorButtonClicked =0;
                            });
                          } else {
                            setState(() {
                              isEditButtonClicked = 0;
                              isColorButtonClicked=1;
                            });
                          }
                        },
                        child: const Icon(Icons.edit)),
                  ] else ...[
                    Container()
                  ],
                ],
              ),
            ),
            // PointerScreen
            // strokes: _strokes,
            // ),
          ],
        ),
      ],
    ));
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

class ColorButton extends StatelessWidget {
  const ColorButton({
    Key? key,
    required this.color,
    required this.sfunction,
  }) : super(key: key);
  final Color color;
  final VoidCallback sfunction;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sfunction,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        height: 50,
        width: 50,
        color: color,
      ),
    );
  }
}


