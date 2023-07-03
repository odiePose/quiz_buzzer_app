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
                        Text(firstBuzzerName + ' has buzzed!'),
                        ElevatedButton(
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
                            child: const Text('Riktig sang (+1)')),
                        ElevatedButton(
                            onPressed: () async {
                              ref.read(continue_.notifier).state = 1;
                              // Resetting the active property of each player for the next round
                              for (var player in gameState['players']) {
                                player['active'] = true;
                              }
                              await supabase.from('game_state').update({
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
                            child: const Text('Riktig artist (+1)')),
                        ElevatedButton(
                            onPressed: () async {
                              ref.read(continue_.notifier).state = 1;
                              // Resetting the active property of each player for the next round
                              for (var player in gameState['players']) {
                                player['active'] = true;
                              }
                              await supabase.from('game_state').update({
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
                            child: const Text('Begge riktig (+2)')),
                        ElevatedButton(
                            onPressed: () async {
                              await supabase.from('game_state').update({
                                'state_of_game': 1,
                                'players': [
                                  {
                                    'id': firstBuzzId,
                                    'name': firstBuzzerName,
                                    'active': false,
                                  },
                                  ...gameState['players'].where(
                                      (player) => player['id'] != firstBuzzId)
                                ]
                              }).eq('id', roomId);
                            },
                            child: const Text('Feil svar')),
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
                    Text('Waiting for a buzz...'),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const Center(child: Text('Error'))));
  }
}
