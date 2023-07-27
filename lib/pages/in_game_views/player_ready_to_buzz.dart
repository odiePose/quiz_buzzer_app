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
                        'BUZZ \n FOR FAEN!!!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 30),
                      )),
                    ),
                  ),
                ),
              );
            } else if (gameState == GameState.showingScoreboard.index) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      'Waiting for host to continue',
                      style: GoogleFonts.poppins(
                          fontSize: 35, fontWeight: FontWeight.w600),
                    ),
                    for (var player in data[0]['players'])
                      Text(
                        player['name'] + ': ' + player['score'].toString(),
                        style: GoogleFonts.poppins(fontSize: 30),
                      ),
                  ],
                ),
              );
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
                                  fontSize: 25, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'You were the first to buzz!',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 50),
                          ]
                        : [
                            Text(
                              'Waiting for host to give points...',
                              style: GoogleFonts.poppins(
                                  fontSize: 25, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 50),
                            const Text('Too late!',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600)),
                            Text(
                              nameOfPlayer(
                                  data[0]['first_buzz_id'], data[0]['players']),
                              style: const TextStyle(fontSize: 25),
                            ),
                            const Text(
                              'was the first to buzz!',
                              style: TextStyle(fontSize: 20),
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
}

String nameOfPlayer(int id, List<dynamic> players) {
  return players.firstWhere((player) => player['id'] == id)['name'];
}
