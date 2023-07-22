import 'package:beat_blitz/pages/home_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final roomIdProvider = StateProvider<String>((ref) => '');

final roomStreamProvider = StreamProvider.family((ref, roomId) {
  final supabase = ref.watch(supabaseProvider);
  return supabase
      .from('game_state')
      .stream(primaryKey: ['id']).eq('id', roomId);
});

enum GameState {
  notStarted,
  showingScoreboard,
  showingBuzzer,
  inGame,
}
