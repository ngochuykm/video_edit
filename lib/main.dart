import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_video_info/flutter_video_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _video;
  File _cameraVideo;
  double _videoinfo;
  List<int> timeFrame = [0,1000];

  ImagePicker picker = ImagePicker();

  VideoPlayerController _videoPlayerController;
  VideoPlayerController _cameraVideoPlayerController;

  // This funcion will helps you to pick and Image from Gallery

  // This funcion will helps you to pick a Video File
  _pickVideo() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);

    _video = File(pickedFile.path);
    final _info = await _getvideoinfo(pickedFile.path);

    _videoPlayerController = VideoPlayerController.file(_video)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _videoinfo = _info;
        print(_info);
      });
  }

  // This funcion will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile.path);

    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.play();
      });
  }
  _seekvideo(time) async {
    print(" seek video ::: " + _video.path);
    setState(() {
      if(_videoPlayerController!=null ){
        _videoPlayerController.seekTo(Duration(milliseconds: time));
        _videoPlayerController.pause();
        }
    });
  }
  _playvideo() async {
    print(" play video ::: ");
    setState(() {
      _videoPlayerController.play();
    });
  }
  _getvideoinfo(path) async {
    if(_video!=null){
      final videoInfo = FlutterVideoInfo();
      final videoinfo = await videoInfo.getVideoInfo(path);
      print(videoinfo.duration);
      print("data from get video info ::: " + _videoinfo.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image / Video Picker"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (_video != null)
                  _videoPlayerController.value.initialized
                      ? AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        )
                      : Container()
                else
                  Text(
                    "Click on Pick Video to select video",
                    style: TextStyle(fontSize: 18.0),
                  ),
                RaisedButton(
                  onPressed: () {
                    _pickVideo();
                  },
                  child: Text("Pick Video From Gallery"),
                ),
                if (_cameraVideo != null)
                  _cameraVideoPlayerController.value.initialized
                      ? AspectRatio(
                          aspectRatio:
                              _cameraVideoPlayerController.value.aspectRatio,
                          child: Column(
                                    children: [
                                      VideoPlayer(_cameraVideoPlayerController),
                                      if(_video!=null) ValueListenableBuilder(
                                        valueListenable: _videoPlayerController,
                                        builder: (context, VideoPlayerValue value, child) {
                                          //Do Something with the value.
                                          return Text(value.position.toString());
                                        },
                                      ),
                                    ],
                                  ),
                        )
                      : Container()
                else
                  Text(
                    "Click on Pick Video to select video",
                    style: TextStyle(fontSize: 18.0),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                    onPressed: () {
                      _seekvideo(1500);
                    },
                    child: Text("Seek"),
                    ),
                    RaisedButton(
                    onPressed: () {
                      _playvideo();
                    },
                    child: Text("Play"),
                    ),
                    RaisedButton(
                    onPressed: () {
                      _getvideoinfo(_video.path);
                    },
                    child: Text("Info"),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top:10)),
                if(_video!=null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  children: [
                    FlatButton(
                      onPressed:() => _seekvideo(0), 
                      child: RenderFrame(_video.path,0000),
                      ),
                    FlatButton(
                      onPressed:() => _seekvideo(1000), 
                      child: RenderFrame(_video.path,1000),
                      ),
                    FlatButton(
                      onPressed:() => _seekvideo(2000), 
                      child: RenderFrame(_video.path,2000),
                      ),
                    FlatButton(
                      onPressed:() => _seekvideo(3000), 
                      child: RenderFrame(_video.path,3000),
                      ),
                  ],
                ),)
                ,
                Padding(
                  padding: EdgeInsets.only(top:10),
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                Text(_videoinfo.toString()),  
                RaisedButton(
                  onPressed: () {
                    _pickVideoFromCamera();
                  },
                  child: Text("Pick Video From Camera"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RenderFrame extends StatelessWidget{
  final String path;
  final int time;
  _getframe(time) async {
    print(" get frame ::: ");
    final fileName = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
      timeMs: time
    );
    return fileName;
  }

  RenderFrame(this.path,this.time);
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.only(left:10,right:10),
      child: FutureBuilder<dynamic>(
        future: _getframe(time),
        builder: (context, snapot){
          return Column(
            children: [
              if(snapot.data!=null) Image.memory(snapot.data),
              Padding(padding: EdgeInsets.only(top: 3)),
              Text("Form : " + (time/1000).toString() + "s",style: TextStyle(color: Colors.blueAccent, fontSize: 10,fontFamily: 'Raleway'))
            ],
          );
        },
      )
    );
  } 
}
