import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audiobook/pages/audio/Books.dart';
import 'package:audiobook/pages/audio/SettingBook.dart';
import 'package:audiobook/widgets/SeekBar.dart';
import 'package:audiobook/provide/audio_provide.dart';
import 'package:audiobook/utils/LocalStorage.dart';
import 'package:audiobook/widgets/EmptyImage.dart';
import 'package:rxdart/rxdart.dart';

class Audio extends StatefulWidget {
  const Audio({super.key});

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecord();
    });
  }

// 滚动到当前集 | scroll to current episode
  void scrollToItem(int index) {
    double itemHeight = 50.0;
    double scrollPosition = index * itemHeight;
    _scrollController.animateTo(scrollPosition,
        duration: const Duration(milliseconds: 30), curve: Curves.easeOut);
  }

  Future getRecord() async {
    var res = await LocalStorage.getPlayRecordVal();
    if (res != null) {
      try {
        await Future.delayed(const Duration(milliseconds: 600));
        scrollToItem(res[0]);
      } catch (e) {
        print(e);
      }
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Audio book"),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SettingBook()));
              },
              icon: Icon(Icons.settings_applications_sharp)),
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Books())),
              icon: Icon(Icons.book))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    return const SizedBox();
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: CachedNetworkImage(
                              width: 400,
                              height: 400,
                              imageUrl: '${metadata.artUri!}',
                              errorWidget: (context, url, error) => EmptyImage(
                                size: 250,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(metadata.album!,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(metadata.title),
                    ],
                  );
                },
              ),
            ),
            ControlButtons(player),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    player.seek(newPosition);
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 240.0,
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView(
                    controller: _scrollController,
                    children: [
                      for (var i = 0; i < sequence.length; i++)
                        Container(
                          height: 50,
                          child: Material(
                            color: i == state!.currentIndex
                                ? Theme.of(context).primaryColorLight
                                : Colors.grey.shade200,
                            child: ListTile(
                              title: Text(sequence[i].tag.title as String),
                              onTap: () async {
                                await player.seek(Duration.zero, index: i);

                                player.play();
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              icon: const Icon(Icons.replay_10_rounded),
              iconSize: 44.0,
              onPressed: player.duration != null
                  ? () => player.seek(
                      (positionData ?? Duration.zero) - Duration(seconds: 10))
                  : null,
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            iconSize: 44.0,
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 44.0,
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              icon: const Icon(Icons.forward_10_rounded),
              iconSize: 44.0,
              onPressed: player.duration != null
                  ? () => player.seek(
                      (positionData ?? Duration.zero) + Duration(seconds: 10))
                  : null,
            );
          },
        ),
      ],
    );
  }
}
