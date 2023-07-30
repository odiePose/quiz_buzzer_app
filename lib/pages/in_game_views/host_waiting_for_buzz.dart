import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WaitingForBuzz extends HookConsumerWidget {
  const WaitingForBuzz(this.roomId, {super.key});
  final int roomId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomValue = ref.watch(roomStreamProvider(roomId));
    final supabase = ref.watch(supabaseProvider);
    return Scaffold(
        body: roomValue.when(
            data: (data) {
              final gameData = data[0];
              final firstBuzzId = gameData['first_buzz_id'];
              final gameState = gameData['state_of_game'];
              if (gameState == GameState.showingBuzzer.index) {
                final firstBuzzUser = gameData['players']
                    .firstWhere((player) => player['id'] == firstBuzzId);
                final firstBuzzerName = firstBuzzUser['name'];
                final firstBuzzerScore = firstBuzzUser['score'];
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width),
                      Text(
                        firstBuzzerName + ' has buzzed!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 25),
                      ),
                      DecisionButton(
                        text: 'Enten riktig sang eller artist (+1)',
                        onPressed: () async {
                          // Resetting the active property of each player for the next round
                          for (var player in gameData['players']) {
                            player['active'] = true;
                          }

                          await supabase.from('game_state').update({
                            'first_buzz_id': null,
                            'state_of_game': GameState.showingScoreboard.index,
                            'players': [
                              {
                                'id': firstBuzzId,
                                'name': firstBuzzerName,
                                'score': firstBuzzerScore + 1,
                              },
                              ...gameData['players'].where(
                                  (player) => player['id'] != firstBuzzId)
                            ]
                          }).eq('id', roomId);
                        },
                      ),
                      DecisionButton(
                        text: 'Begge riktig (+2)',
                        onPressed: () async {
                          // Resetting the active property of each player for the next round
                          for (var player in gameData['players']) {
                            player['active'] = true;
                          }
                          await supabase.from('game_state').update({
                            'first_buzz_id': null,
                            'state_of_game': GameState.showingScoreboard.index,
                            'players': [
                              {
                                'id': firstBuzzId,
                                'name': firstBuzzerName,
                                'score': firstBuzzerScore + 2,
                              },
                              ...gameData['players'].where(
                                  (player) => player['id'] != firstBuzzId)
                            ]
                          }).eq('id', roomId);
                        },
                      ),
                      DecisionButton(
                        text: 'Feil svar',
                        onPressed: () async {
                          await supabase.from('game_state').update({
                            'first_buzz_id': null,
                            'state_of_game': GameState.inGame.index,
                            'players': [
                              {
                                'id': firstBuzzId,
                                'name': firstBuzzerName,
                                'active': false,
                                'score': firstBuzzerScore,
                              },
                              ...gameData['players'].where(
                                  (player) => player['id'] != firstBuzzId)
                            ]
                          }).eq('id', roomId);
                        },
                      )
                    ]);
              } else if (gameState == GameState.showingScoreboard.index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width),
                    DecisionButton(
                        onPressed: () async {
                          await supabase.from('game_state').update({
                            'first_buzz_id': null,
                            'state_of_game': GameState.inGame.index
                          }).eq('id', roomId);
                        },
                        text: ('Fortsett til neste runde')),
                    DecisionButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        },
                        text: 'Avslutt spillet'),
                  ],
                );
              } else if (gameState == GameState.inGame.index) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Waiting for a buzz...',
                          style: TextStyle(fontSize: 25)),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Error'),
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const Center(child: Text('Error'))));
  }
}

class DecisionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const DecisionButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(25.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.deepPurple,
          ),
          onPressed: onPressed,
          child: Text(text)),
    );
  }
}
