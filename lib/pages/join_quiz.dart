import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:beat_blitz/pages/in_game_views/player_ready_to_buzz.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final nameProvider = StateProvider<String>((ref) => '');
final playerIdProvider = StateProvider<int>((ref) => 0);

class JoinQuiz extends HookConsumerWidget {
  const JoinQuiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SupabaseClient supabase = ref.watch(supabaseProvider);
    final roomId = ref.watch(roomIdProvider);
    final name = ref.watch(nameProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Quiz'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Enter the room ID to join a quiz'),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                onChanged: (value) {
                  ref.read(roomIdProvider.notifier).state = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Room ID',
                ),
              ),
              const SizedBox(height: 40),
              const Text('Enter name'),
              TextField(
                maxLength: 10,
                onChanged: (value) {
                  ref.read(nameProvider.notifier).state = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final data = await supabase
                .from('game_state')
                .select('id, players')
                .eq('id', int.parse(roomId));

            await supabase.from('game_state').update({
              'players': [
                ...data![0]['players'],
                {
                  'id': data![0]['players'].length + 1,
                  'name': name,
                  'active': true,
                  'score': 0
                }
              ]
            }).eq('id', int.parse(roomId));
            ref.read(playerIdProvider.notifier).state =
                data![0]['players'].length + 1;

            if ((data != null) && context.mounted) {
              Navigator.push(
                context,
                NoAnimationPageRoute(
                  builder: (context) =>
                      PlayerBuzzView(roomId: int.parse(roomId)),
                ),
              );
            }
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class PlayerJoinedRoom extends HookConsumerWidget {
  const PlayerJoinedRoom({required this.roomId, Key? key}) : super(key: key);
  final int roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersValue = ref.watch(roomStreamProvider(roomId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for host to start'),
      ),
      body: playersValue.when(data: (data) {
        final gameState = data[0];
        if (gameState['state_of_game'] != GameState.notStarted.index) {
          return PlayerBuzzView(roomId: roomId);
        }
        final players = gameState['players'] as List<dynamic>;
        //final host = gameState['host'];
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              const Text(
                'Waiting for host to start...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 50),
              //Text('Host: $host'),
              Expanded(
                  child: ListView(
                children: [
                  const Text('Joined players:',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  ...players.map((player) {
                    return Text(player['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20));
                  }).toList()
                ],
              )),
            ],
          ),
        );
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }, error: (error, stackTrace) {
        return const Center(
          child: Text('Error'),
        );
      }),
    );
  }
}

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute(
      {required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
