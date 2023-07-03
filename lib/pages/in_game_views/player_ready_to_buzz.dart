import 'package:avatar_glow/avatar_glow.dart';
import 'package:beat_blitz/game_state_providers.dart';
import 'package:beat_blitz/pages/home_page.dart';
import 'package:beat_blitz/pages/join_quiz.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayerBuzzView extends HookConsumerWidget {
  const PlayerBuzzView(this.roomId, {Key? key}) : super(key: key);
  final int roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersValue = ref.watch(roomStreamProvider(roomId));
    final supabase = ref.watch(supabaseProvider);
    final playerid = ref.watch(playerIdProvider);
    return playersValue.when(
      data: (data) {
        if (data[0]['first_buzz_id'] == null) {
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
                await supabase
                    .from('game_state')
                    .update({'first_buzz_id': playerid}).eq('id', roomId);
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
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 30),
                  )),
                ),
              ),
            ),
          );
        }
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(child: Text('Error')),
    );
  }
}
