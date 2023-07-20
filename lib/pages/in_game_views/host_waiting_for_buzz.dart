import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final continue_ = StateProvider((ref) => 0);

class WaitingForBuzz extends HookConsumerWidget {
  const WaitingForBuzz(this.roomId, {super.key});
  final int roomId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomValue = ref.watch(roomStreamProvider(roomId));
    final supabase = ref.watch(supabaseProvider);
    final continueVar = ref.watch(continue_);
    return Scaffold(
        body: roomValue.when(
            data: (data) {
              final gameState = data[0];
              final firstBuzzId = gameState['first_buzz_id'];
              if (firstBuzzId != null) {
                final firstBuzzUser = gameState['players']
                    .firstWhere((player) => player['id'] == firstBuzzId);
                final firstBuzzerName = firstBuzzUser['name'];
                final firstBuzzerScore = firstBuzzUser['score'];
                if (continueVar == 0) {
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
                            ref.read(continue_.notifier).state = 1;
                            // Resetting the active property of each player for the next round
                            for (var player in gameState['players']) {
                              player['active'] = true;
                            }
                            await supabase.from('game_state').update({
                              'first_buzz_id': null,
                              'state_of_game': 1,
                              'players': [
                                {
                                  'id': firstBuzzId,
                                  'name': firstBuzzerName,
                                  'score': firstBuzzerScore + 1,
                                },
                                ...gameState['players'].where(
                                    (player) => player['id'] != firstBuzzId)
                              ]
                            }).eq('id', roomId);
                          },
                        ),
                        DecisionButton(
                          text: 'Begge riktig (+2)',
                          onPressed: () async {
                            ref.read(continue_.notifier).state = 1;
                            // Resetting the active property of each player for the next round
                            for (var player in gameState['players']) {
                              player['active'] = true;
                            }
                            await supabase.from('game_state').update({
                              'first_buzz_id': null,
                              'state_of_game': 1,
                              'players': [
                                {
                                  'id': firstBuzzId,
                                  'name': firstBuzzerName,
                                  'score': firstBuzzerScore + 2,
                                },
                                ...gameState['players'].where(
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
                              'state_of_game': 1,
                              'players': [
                                {
                                  'id': firstBuzzId,
                                  'name': firstBuzzerName,
                                  'active': false,
                                  'score': firstBuzzerScore,
                                },
                                ...gameState['players'].where(
                                    (player) => player['id'] != firstBuzzId)
                              ]
                            }).eq('id', roomId);
                          },
                        )
                      ]);
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            ref.read(continue_.notifier).state = 0;
                            await supabase.from('game_state').update({
                              'first_buzz_id': null,
                            }).eq('id', roomId);
                          },
                          child: const Text('Fortsett til neste runde')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          },
                          child: const Text('Avslutt spillet')),
                    ],
                  );
                }
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Waiting for a buzz...',
                        style: TextStyle(fontSize: 25)),
                  ],
                ),
              );
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
