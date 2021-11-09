import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class VideoProcessor {
  final FlutterFFmpeg ffmpeg;

  VideoProcessor({@required this.ffmpeg});

  static const combinedVideoBaseName = 'combined_video.mp4';

  ///Extract, decode and cut audio track from video file
  Future<String> extractAudio(String path) async {
    var appDocumentDirectory = await getApplicationDocumentsDirectory();

    //Prepare empty file for audio output
    var audioPath = '${appDocumentDirectory.path}/output-audio.wav';

    //Command for Ffmpeg library
    var command = '-y -i $path -ss 00:00:00 -to 00:00:59.900 -ac 1 -ar 16000 $audioPath';

    //Execute command
    var result = await ffmpeg.execute(command);
    return audioPath;
  }

  Future<String> cutVideo(String path, String outputName) async {
    var appDocumentDirectory = await getApplicationDocumentsDirectory();

    var videoPath = '${appDocumentDirectory.path}/$outputName.mp4';

    //Command for Ffmpeg library
    var command =
        '-y -i  $path -ss 00:00:00 -to 00:00:59.900 -r 30 -vf  \"[in]scale=iw*min(1920/iw\\,1080/ih):ih*min(1920/iw\\,1080/ih)[scaled]; [scaled]pad=1920:1080:(1920-iw*min(1920/iw\\,1080/ih))/2:(1080-ih*min(1920/iw\\,1080/ih))/2[padded]; [padded]setsar=1:1[out]\" -c:a copy $videoPath';

    //Execute command
    await ffmpeg.execute(command);
    print('cutVideo videoPath: $videoPath');
    return videoPath;
  }

  Future<String> combineVideosReturnFileName(List<String> files) async {
    var appDocumentDirectory = await getApplicationDocumentsDirectory();
    if (files.length == 1) {
      var finalFilePath = '${appDocumentDirectory.path}/${combinedVideoBaseName}';
      var finalVideo = await File(files.first).copy(finalFilePath);
      return combinedVideoBaseName;
      // return finalVideo.path;
    }

    var extractedAudioList = <String>[];
    ///extract audio from each videos
    for (final filePathWithName in files) {
      var audioFileName = 'audio_${basenameWithoutExtension(filePathWithName)}.wav';
      var audioFilePathWithName = '${dirname(filePathWithName)}/$audioFileName';
      var extractingAudioCommand = '-i $filePathWithName -vn $audioFilePathWithName';
      var result = await ffmpeg.execute(extractingAudioCommand);
      var isExist = await File(audioFilePathWithName).exists();
      extractedAudioList.add(audioFilePathWithName);
    }

    ///creating txt file of audios
    var audiosFilePath = '${appDocumentDirectory.path}/audios.txt';
    var audioListFile = await File(audiosFilePath).create();

    print('Start concat audios');
    ///concat audios
    var finalAudioFilePath = '${dirname(audiosFilePath)}/${basenameWithoutExtension(audiosFilePath)}.wav';

    String concatAudiosCommand = '-y ';
    for (final audioPath in extractedAudioList) {
      concatAudiosCommand += '-i $audioPath ';
    }
    concatAudiosCommand += '-filter_complex \'';
    for (var i = 0; i < extractedAudioList.length; i++) {
      concatAudiosCommand += '[$i:0]';
    }
    concatAudiosCommand += 'concat=n=${extractedAudioList.length}:v=0:a=1[out]\' -map \'[out]\' $finalAudioFilePath';

    var concatAudiosCommandResult = await ffmpeg.execute(concatAudiosCommand);
    var fileAudio = File(finalAudioFilePath);
    var isAudioExist = await fileAudio.exists();

    ///remove audio from each videos and save new videos
    var videoWithoutAudioList = <String>[];
    for (final filePathWithName in files) {
      var videoFileName = 'video_${basename(filePathWithName)}';
      var videoFilePathWithName = '${dirname(filePathWithName)}/$videoFileName';
      var creatingVideosWithoutAudioCommand = '-i $filePathWithName -an -c:v copy $videoFilePathWithName';
      var creatingVideosWithoutAudioCommandResult = await ffmpeg.execute(creatingVideosWithoutAudioCommand);
      var isExist = await File(videoFilePathWithName).exists();
      videoWithoutAudioList.add(videoFilePathWithName);
    }

    ///creating txt file of videos
    var videosFilePath = '${appDocumentDirectory.path}/videos.txt';
    var videoListFile = await File(videosFilePath).create();
    var videosFilePathList = '';
    videoWithoutAudioList.forEach((file) {
      videosFilePathList += "file '$file'\n";
    });
    await videoListFile.writeAsString(videosFilePathList);

    ///concat videos
    var finalVideoFilePath = '${dirname(videosFilePath)}/${basenameWithoutExtension(videosFilePath)}.mp4';
    var concatVideosCommand = '-safe 0 -f concat -i $videosFilePath -c copy $finalVideoFilePath';
    var concatVideosCommandResult = await ffmpeg.execute(concatVideosCommand);
    var fileVideo = File(finalVideoFilePath);
    var isVideoExist = await fileVideo.exists();

    ///concat final video and audio
    var finalFilePath = '${dirname(videosFilePath)}/${combinedVideoBaseName}';
    var concatFinalVideoAndAudioCommand = '-i $finalVideoFilePath -i $finalAudioFilePath -c:v copy -c:a aac $finalFilePath';
    var finalVideo = File(finalFilePath);
    var concatFinalVideoAndAudioCommandResult = await ffmpeg.execute(concatFinalVideoAndAudioCommand);

    ///removing garbage files
    var isAudioListFileExist = await audioListFile.exists();
    if (isAudioListFileExist) {
      await audioListFile.delete();
    }
    for (final audioFile in extractedAudioList) {
      var isExist = await File(audioFile).exists();
      if (isExist) {
        await File(audioFile).delete();
      }
    }
    var isVideoListFileExist = await videoListFile.exists();
    if (isVideoListFileExist) {
      await videoListFile.delete();
    }
    for (final videoFile in videoWithoutAudioList) {
      var isExist = await File(videoFile).exists();
      if (isExist) {
        await File(videoFile).delete();
      }
    }
    var audioExist = await fileAudio.exists();
    if (audioExist) {
      await fileAudio.delete();
    }
    var videoExist = await fileVideo.exists();
    if (videoExist) {
      await fileVideo.delete();
    }

    // return Pathes(finalFilePath, finalAudioFilePath);
    // return finalFilePath;
    return basename(finalFilePath);
  }
}

class Pathes{
  String videoPath;
  String audioPath;

  Pathes(this.videoPath, this.audioPath);
}