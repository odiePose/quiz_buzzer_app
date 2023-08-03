import 'package:avatar_glow/avatar_glow.dart';
import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:beat_blitz/pages/join_quiz.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayerBuzzView extends HookConsumerWidget {
  const PlayerBuzzView({required this.roomId, Key? key}) : super(key: key);
  final int roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersValue = ref.watch(roomStreamProvider(roomId));
    final supabase = ref.watch(supabaseProvider);
    final playerid = ref.watch(playerIdProvider);

    return Scaffold(
        appBar: AppBar(),
        body: playersValue.when(
          data: (data) {
            final gameData = data[0];
            final gameState = data[0]['state_of_game'];
            if (gameState == GameState.inGame.index) {
              final player = data[0]['players']
                  .firstWhere((player) => player['id'] == playerid);
              if (player['active'] == false) {
                return Center(
                  child: Text('You have already buzzed this round',
                      style: GoogleFonts.poppins(fontSize: 20)),
                );
              }
              return Center(
                child: GestureDetector(
                  onTap: () async {
                    await supabase.from('game_state').update({
                      'first_buzz_id': playerid,
                      'state_of_game': GameState.showingBuzzer.index
                    }).eq('id', roomId);
                  },
                  child: AvatarGlow(
                    endRadius: MediaQuery.of(context).size.width * 0.55,
                    shape: BoxShape.circle,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(boxShadow: const [
                        BoxShadow(blurRadius: 20, color: Colors.black26)
                      ], color: Colors.green.shade800, shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                        'BUZZ!!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 30),
                      )),
                    ),
                  ),
                ),
              );
            } else if (gameState == GameState.showingScoreboard.index) {
              return ScoreboardScreen(data[0], context);
            } else if (gameState == GameState.showingBuzzer.index) {
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: data[0]['first_buzz_id'] == playerid
                        ? [
                            Text(
                              'Waiting for host to give points',
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'You were the first to buzz!',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                          ]
                        : [
                            Text(
                              'Waiting for host to give points...',
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'Too late!',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              nameOfPlayer(
                                  data[0]['first_buzz_id'], data[0]['players']),
                              style: const TextStyle(fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'was the first to buzz!',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ]),
              );
            } else if (gameState == GameState.notStarted.index) {
              final players = gameData['players'] as List<dynamic>;
              //final host = gameState['host'];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    const Text(
                      'Waiting for host to start...',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 50),
                    //Text('Host: $host'),
                    Expanded(
                        child: ListView(
                      children: [
                        const Text('Joined players:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600)),
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
            } else {
              return Container();
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(child: Text('Error')),
        ));
  }

  Center ScoreboardScreen(Map<String, dynamic> data, BuildContext context) {
    final players = data['players'] as List<dynamic>;
    final playerNames = namesOfPlayersOrderedByScore(players);

    return Center(
      child: Column(
        children: [
          Text(
            'Waiting for host to continue',
            style:
                GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildPodiumContainer(Colors.grey, 2, context),
              buildPodiumContainer(Colors.yellow, 1, context),
              buildPodiumContainer(Colors.brown, 3, context)
            ],
          ),
          for (var i = 3; i < playerNames.length; i++)
            Text(
              '${i + 1}. ${playerNames[i]}',
              style: GoogleFonts.poppins(fontSize: 30),
            ),
        ],
      ),
    );
  }
}

String nameOfPlayer(int id, List<dynamic> players) {
  return players.firstWhere((player) => player['id'] == id)['name'];
}

List<dynamic> namesOfPlayersOrderedByScore(List<dynamic> players) {
  final playersSortedByScore = players
    ..sort((a, b) => b['score'].compareTo(a['score']));
  return playersSortedByScore.map((player) => player['name']).toList();
}

Widget buildPodiumContainer(Color color, int position, BuildContext context) {
  final double containerHeight = MediaQuery.of(context).size.height * 0.3;
  final double containerWidth = MediaQuery.of(context).size.width * 0.2;

  return Container(
    height: position == 1
        ? containerHeight
        : position == 2
            ? containerHeight * 0.8
            : containerHeight * 0.6,
    width: containerWidth,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        'Player $position', // Replace with actual player names
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
