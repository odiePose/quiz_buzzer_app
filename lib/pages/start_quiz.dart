import 'package:avatar_glow/avatar_glow.dart';
import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:beat_blitz/pages/in_game_views/host_waiting_for_buzz.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartQuizPage extends HookConsumerWidget {
  const StartQuizPage(this.roomId, {Key? key}) : super(key: key);
  final int roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersValue = ref.watch(roomStreamProvider(roomId));
    final SupabaseClient supabase = ref.watch(supabaseProvider);
    return playersValue.when(
        data: (data) => data[0]['state_of_game'] == GameState.notStarted.index
            ? Scaffold(
                backgroundColor: const Color(0xFFdddef2),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.black,
                ),
                body: SafeArea(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 100),
                            Column(
                              children: [
                                Text(
                                  'Your code:',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  roomId.toString(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 55,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            const SizedBox(height: 50),
                            Column(
                              children: [
                                Text(
                                  'Joined users:',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600),
                                ),
                                playersValue.when(
                                    data: (players) {
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Text(
                                                players[0]['players'][index]
                                                        ['name']
                                                    .toString(),
                                                textAlign: TextAlign.center);
                                          },
                                          itemCount:
                                              players[0]['players'].length);
                                    },
                                    error: (e, st) => ErrorWidget(e.toString()),
                                    loading: () =>
                                        const CircularProgressIndicator())
                              ],
                            ),
                          ],
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                await supabase.from('game_state').update({
                                  'state_of_game': GameState.inGame.index,
                                }).eq('id', roomId);
                              } catch (e) {
                                // ignore: avoid_print
                                print(e);
                              }
                            },
                            child: AvatarGlow(
                              endRadius: 110,
                              shape: BoxShape.circle,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 20, color: Colors.black26)
                                    ],
                                    color: Colors.green.shade800,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(
                                  'START',
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                )),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              )
            : WaitingForBuzz(roomId),
        loading: () => Container(),
        error: (e, st) => ErrorWidget(e.toString()));
  }
}
