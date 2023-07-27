import 'package:beat_blitz/constants.dart';
import 'package:beat_blitz/pages/join_quiz.dart';
import 'package:beat_blitz/pages/start_quiz.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

final supabaseProvider = Provider((ref) {
  final credentials = Constants.getSupaBaseCredentials();
  return SupabaseClient(credentials[0], credentials[1]);
});

final loadingProvider = StateProvider((ref) => false);

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SupabaseClient supabase = ref.watch(supabaseProvider);
    final loading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFdddef2),
      body: Stack(children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 130,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 40),
                          ),
                          Text("Let's start quizzing",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF969696),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                        ],
                      ),
                      Image.asset(
                        'assets/3d_icons/lightning.png',
                        height: 130,
                        fit: BoxFit.fitHeight,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () async {
                    ref.read(loadingProvider.notifier).state = true;
                    String hostId = '6db277a6-0f92-486f-a1df-44fe387937f7';
                    try {
                      final room = await supabase.from('game_state').insert({
                        'host': hostId,
                        'name': '',
                        'first_buzz_id': null,
                        'players': []
                      }).select();

                      // Get the ID of the newly created room
                      final roomId = room[0]['id'];
                      await Future.delayed(const Duration(seconds: 1));
                      if (context.mounted) {
                        ref.read(loadingProvider.notifier).state = false;
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => StartQuizPage(roomId)));
                      }
                    } catch (e) {
                      // ignore: avoid_print
                      print(e);
                    }
                  },
                  child: SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          height: 140,
                          constraints: const BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 20,
                                    color: Colors.black.withOpacity(0.2))
                              ],
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFFFC9E3)),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Start a new quiz',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF7D3773),
                                    fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 160,
                            child: Image.asset(
                              'assets/3d_characters/girl.png',
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (context.mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const JoinQuiz()));
                    }
                  },
                  child: SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          height: 140,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 20,
                                    color: Colors.black.withOpacity(0.2))
                              ],
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFB8FABE)),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Join a quiz',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3E7844),
                                    fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 160,
                            child: Image.asset(
                              'assets/3d_characters/boy.png',
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 80,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return Container();
                      /* final adValue = ref.watch(adInitProvider);
                      return adValue.when(
                          data: (adInit) {
                            return const AdView();
                          },
                          error: (e, st) => ErrorWidget(e),
                          loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ));
                              */
                    },
                  ),
                ),
                /*
                GestureDetector(
                    onTap: () {},
                    child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black.withOpacity(0.2))
                            ],
                            color: const Color(0xFFFEE3A7),
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Text(
                            'Sign out',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF735B23),
                                fontSize: 30,
                                fontWeight: FontWeight.w500),
                          ),
                        )))
                        */
              ],
            ),
          ),
        ),
        loading
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(child: CircularProgressIndicator()))
            : const SizedBox(),
      ]),
    );
  }
}
