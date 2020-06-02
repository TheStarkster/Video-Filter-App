import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart' as PackagageVideoPlayer;

class PlayRecordedVideo extends StatefulWidget {
  final String path;
  PlayRecordedVideo({@required this.path});
  @override
  _PlayRecordedVideoState createState() => _PlayRecordedVideoState();
}

class _PlayRecordedVideoState extends State<PlayRecordedVideo> {
  FlutterFFmpeg fFmpeg;
  PackagageVideoPlayer.VideoPlayerController _controller;
  File fileInfo;
  final spinkit = SpinKitChasingDots(
    color: Colors.white,
    size: 50.0,
  );
  void getVideo() async {
    fileInfo = File(widget.path);
    _controller = PackagageVideoPlayer.VideoPlayerController.file(fileInfo)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
        });
      });
  }

  @override
  void initState() {
    super.initState();
    getVideo();
    fFmpeg = new FlutterFFmpeg();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: _controller == null
          ? spinkit
          : _controller.value.initialized
              ? GestureDetector(
                  onTap: () {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        PackagageVideoPlayer.VideoPlayer(
                          _controller,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: () async {
                                final Directory extDir =
                                    await getApplicationDocumentsDirectory();
                                final String dirPath =
                                    '${extDir.path}/Oyindori/Filtered';
                                await Directory(dirPath)
                                    .create(recursive: true);
                                final String filePath =
                                    '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}';
                                await fFmpeg.execute('-i ' +
                                    widget.path +
                                    ' -vf hue=s=0 ' +
                                    filePath +
                                    '-output.mp4');
                                _controller = PackagageVideoPlayer
                                        .VideoPlayerController
                                    .file(File(filePath + '-output.mp4'))
                                  ..initialize().then((_) {
                                    setState(() {
                                      _controller.play();
                                      _controller.setLooping(true);
                                    });
                                  });
                              },
                              child: Text("Apply Gray Scale Filter"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : spinkit,
    );
  }
}
