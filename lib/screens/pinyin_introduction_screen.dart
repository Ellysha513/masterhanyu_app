import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PinyinIntroScreen extends StatefulWidget {
  const PinyinIntroScreen({super.key});

  @override
  State<PinyinIntroScreen> createState() => _PinyinIntroScreenState();
}

class _PinyinIntroScreenState extends State<PinyinIntroScreen> {
  late final PageController _controller;
  late final AudioPlayer _player;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path));
  }

  void next() {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void back() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  late final List<Widget> pages = [
    _introText(),
    _pinyinVsCharacter(),
    _pinyinSyllableParts(),
    _initialTable(),
    _finalTable(),
    _finishScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 180, 180, 248),
        elevation: 0,
        title: const Text(
          "Pinyin Introduction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => currentPage = i),
              children: pages,
            ),
          ),
          _navigationBar(isLast),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // NAVIGATION BAR
  // ------------------------------------------------------------
  Widget _navigationBar(bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentPage > 0 ? back : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C56D6),
              disabledBackgroundColor: Colors.grey[300],
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          if (isLast)
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = Supabase.instance.client.auth.currentUser!.id;
                await prefs.setDouble('pinyin_intro_progress_$userId', 0.25);

                if (!mounted) return;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C56D6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('CONTINUE'),
            )
          else
            ElevatedButton(
              onPressed: currentPage < pages.length - 1 ? next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C56D6),
                disabledBackgroundColor: Colors.grey[300],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PAGES
  // ------------------------------------------------------------

  Widget _introText() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pinyin',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'is the Chinese language phonetic system. '
            'It is used to mark Mandarin Chinese pronunciation '
            'by the Latin alphabet.',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _pinyinVsCharacter() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Chinese character 八(eight) with Pinyin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            Image.asset('assets/image/syllable_ba1.png', width: 600),
            const SizedBox(height: 50),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.black),
                children: [
                  TextSpan(
                    text:
                        'In Chinese, every character corresponds to one single syllable',
                  ),
                  TextSpan(text: '. Therefore, '),
                  TextSpan(
                    text: 'one syllable',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  TextSpan(text: ' marks the pronunciation of '),
                  TextSpan(
                    text: 'one character',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinyinSyllableParts() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 17, color: Colors.black),
              children: [
                TextSpan(
                  text: 'A typical Pinyin syllable consists of three parts:',
                ),
                TextSpan(
                  text: 'initial, final and tone.',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 40,
                  color: Color.fromARGB(255, 69, 69, 225),
                ),
                onPressed: () => playAudio('audio/syllable/ba.mp3'),
              ),
              const SizedBox(width: 12),
              Image.asset('assets/image/ba1.png', height: 60),
            ],
          ),
          const SizedBox(height: 40),
          _infoTile(
            title: 'Initial',
            onTap:
                () => _showPopup(
                  letter: 'b',
                  audio: 'audio/initial/b.mp3',
                  text:
                      'This is the initial. It is always put at the beginning of a syllable.',
                ),
          ),
          const SizedBox(height: 16),
          _infoTile(
            title: 'Final',
            onTap:
                () => _showPopup(
                  letter: 'ā',
                  audio: 'audio/final/a.mp3',
                  text:
                      'This is the final. The final comes after the initial.'
                      'The line above the "a" indicates the first tone.',
                ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE6C6F5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _initialTable() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Initials / 声母（shēng mǔ）',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 17, color: Colors.black),
            children: [
              TextSpan(text: 'There are '),
              TextSpan(
                text: '23 initials',
                style: TextStyle(color: Colors.deepPurple),
              ),
              TextSpan(
                text:
                    ' in all. Tap on each \n initial to hear its pronunciation.',
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _finalTile(
              'b',
              'audio/initial/b.mp3',
              'The initial "b" sounds like "bo" in "ball".',
            ),
            _finalTile(
              'p',
              'audio/initial/p.mp3',
              'The initial "p" sounds like "po" in "pollution".',
            ),
            _finalTile(
              'm',
              'audio/initial/m.mp3',
              'The initial "m" sounds like "mo" in Malay word "memohon".',
            ),
            _finalTile(
              'f',
              'audio/initial/f.mp3',
              'The initial "f" sounds like "fo" in "for".',
            ),
            _finalTile(
              'd',
              'audio/initial/d.mp3',
              'The initial "d" sounds like "de" in Malay word "dekat".',
            ),
            _finalTile(
              't',
              'audio/initial/t.mp3',
              'The initial "t" sounds like "te" in Malay word "terbaik".',
            ),
            _finalTile(
              'n',
              'audio/initial/n.mp3',
              'The initial "n" sounds like "ne" in Malay word "nelayan".',
            ),
            _finalTile(
              'l',
              'audio/initial/l.mp3',
              'The initial "l" sounds like "le" in Malay word "lemang".',
            ),
            _finalTile(
              'g',
              'audio/initial/g.mp3',
              'The initial "g" sounds like "ge" in Malay word "gerak".',
            ),
            _finalTile(
              'k',
              'audio/initial/k.mp3',
              'The initial "k" sounds like Malay word "ke".',
            ),
            _finalTile(
              'h',
              'audio/initial/h.mp3',
              'The initial "h" sounds like "her".',
            ),
            _finalTile(
              'j',
              'audio/initial/j.mp3',
              'The initial "j" sounds like "ji" in Malay word "jika".',
            ),
            _finalTile(
              'q',
              'audio/initial/q.mp3',
              'The initial "q" sounds like "qi" in Malay word "cis".',
            ),
            _finalTile(
              'x',
              'audio/initial/x.mp3',
              'The initial "x" sounds like "si" in Malay word "sihat".',
            ),
            _finalTile(
              'z',
              'audio/initial/z.mp3',
              'The initial "z" sound is almost like "dz" sound in "kids".',
            ),
            _finalTile(
              'c',
              'audio/initial/c.mp3',
              'The initial "c" sounds like "ts" in "cats".',
            ),
            _finalTile(
              's',
              'audio/initial/s.mp3',
              'The initial "s" sounds like "sir".',
            ),
            _finalTile(
              'zh',
              'audio/initial/zh.mp3',
              'The initial "zh" sounds like "j" in "judge".',
            ),
            _finalTile(
              'ch',
              'audio/initial/ch.mp3',
              'The initial "ch" sounds like "ch" in "church" with the tongue curled upwards.',
            ),
            _finalTile(
              'sh',
              'audio/initial/sh.mp3',
              'The initial "sh" sounds like "sh" in "shirt" with the tongue curled upwards.',
            ),
            _finalTile(
              'r',
              'audio/initial/r.mp3',
              'The initial "r" sounds like "r" in "run".',
            ),
            _finalTile(
              'y',
              'audio/initial/y.mp3',
              'The initial "y" sounds as "ee" in "bee".',
            ),
            _finalTile(
              'w',
              'audio/initial/w.mp3',
              'The initial "w" sounds like "oo" in "woo".',
            ),
          ],
        ),
      ],
    );
  }

  Widget _finalTable() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Finals / 韵母（yùn mǔ）',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 17, color: Colors.black),
            children: [
              TextSpan(text: 'There are '),
              TextSpan(
                text: '35 finals',
                style: TextStyle(color: Colors.deepPurple),
              ),
              TextSpan(
                text:
                    ' in all, 6 are simple finals \n and 29 are compound finals.',
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _finalTile(
              'a',
              'audio/final/a.mp3',
              'The final "a" sounds similar as the Malay word "abang".',
            ),
            _finalTile(
              'ai',
              'audio/final/ai.mp3',
              'The final "ai" sounds similar as English word "I".',
            ),
            _finalTile(
              'ao',
              'audio/final/ao.mp3',
              'The final "ao" sounds similar as "ow" in "now".',
            ),
            _finalTile(
              'an',
              'audio/final/an.mp3',
              'The final "an" sounds similar as the Malay word "ikan".',
            ),
            _finalTile(
              'ang',
              'audio/final/ang.mp3',
              'The final "ang" sounds similar as the Malay word "orang".',
            ),
            _finalTile(
              'o',
              'audio/final/o.mp3',
              'The final "o" sounds similar as the Malay word "Kopi-o".',
            ),
            _finalTile(
              'ou',
              'audio/final/ou.mp3',
              'The final "ou" sounds as "o" in "so".',
            ),
            _finalTile(
              'ong',
              'audio/final/ong.mp3',
              'The final "ong" sounds as a combination of "o" and "ng".',
            ),
            _finalTile(
              'e',
              'audio/final/e.mp3',
              'The final "e" sounds similar as the Malay word "erti".',
            ),
            _finalTile(
              'ei',
              'audio/final/ei.mp3',
              'The final "ei" sounds as "ay" in "hey".',
            ),
            _finalTile(
              'en',
              'audio/final/en.mp3',
              'The final "en" sounds as "en" in "taken".',
            ),
            _finalTile(
              'eng',
              'audio/final/eng.mp3',
              'The final "eng" sounds as as "en" in "taken" but with "ng" at the end.',
            ),
            _finalTile(
              'er',
              'audio/final/er.mp3',
              'The "e" sound should be short and clear, "r" sound should be loud and clear .',
            ),
            _finalTile(
              'i',
              'audio/final/i.mp3',
              'The final "i" sounds similar as the Malay word "ibu".',
            ),
            _finalTile(
              'ia',
              'audio/final/ia.mp3',
              'The final "ia" sounds like "ya".',
            ),
            _finalTile(
              'iao',
              'audio/final/iao.mp3',
              'The final "iao" sounds like "yao".',
            ),
            _finalTile(
              'ian',
              'audio/final/ian.mp3',
              'The final "ian" sounds like "yen".',
            ),
            _finalTile(
              'iang',
              'audio/final/iang.mp3',
              'The final "iang" sounds like "young" in English.',
            ),
            _finalTile(
              'ie',
              'audio/final/ie.mp3',
              'The final "ie" sounds like "ye" as in "yet".',
            ),
            _finalTile(
              'iu',
              'audio/final/iu.mp3',
              'The final "iu" sounds like "you" in English.',
            ),
            _finalTile(
              'in',
              'audio/final/in.mp3',
              'The final "in" sounds like "in" in English.',
            ),
            _finalTile(
              'ing',
              'audio/final/ing.mp3',
              'It sounds like "in" in ink.',
            ),
            _finalTile(
              'iong',
              'audio/final/iong.mp3',
              'The final "iong" sounds like "yong".',
            ),
            _finalTile(
              'u',
              'audio/final/u.mp3',
              'The final "u" sounds similar as the Malay word "ulang".',
            ),
            _finalTile('ua', 'audio/final/ua.mp3', 'It sounds like "wah".'),
            _finalTile('uai', 'audio/final/uai.mp3', 'It sounds like "why".'),
            _finalTile('uan', 'audio/final/uan.mp3', 'It sounds like "wan".'),
            _finalTile(
              'uang',
              'audio/final/uang.mp3',
              'It sounds like Chinese surname "Wong".',
            ),
            _finalTile(
              'uo',
              'audio/final/uo.mp3',
              'It sounds similar as a shorter "owah".',
            ),
            _finalTile(
              'ui',
              'audio/final/ui.mp3',
              'It sounds like English word "way".',
            ),
            _finalTile(
              'un',
              'audio/final/un.mp3',
              'It sounds like English word "one".',
            ),
            _finalTile(
              'ü',
              'audio/final/ü.mp3',
              'To pronounce this sound, say "ee" with rounded lips.',
            ),
            _finalTile('üe', 'audio/final/üe.mp3', 'It sounds like "yue".'),
            _finalTile('üan', 'audio/final/üan.mp3', 'It sounds like "yuan".'),
            _finalTile('ün', 'audio/final/ün.mp3', 'It sounds like "yun".'),
          ],
        ),
      ],
    );
  }

  Widget _finalTile(String letter, String audio, String text) {
    return GestureDetector(
      onTap: () => _showPopup(letter: letter, audio: audio, text: text),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 168, 244),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _finishScreen() {
    return _FinishScreenWithAudio(
      onAudioPlay: () => playAudio('audio/finish.mp3'),
    );
  }

  // ------------------------------------------------------------
  // POPUP
  // ------------------------------------------------------------
  void _showPopup({
    required String letter,
    required String audio,
    required String text,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Color.fromARGB(255, 69, 69, 225),
                      size: 36,
                    ),
                    onPressed: () => playAudio(audio),
                  ),
                  Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(text, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
    );
  }
}

// ============================================================
// FINISH SCREEN (TOP-LEVEL — REQUIRED)
// ============================================================
class _FinishScreenWithAudio extends StatefulWidget {
  final VoidCallback onAudioPlay;

  const _FinishScreenWithAudio({required this.onAudioPlay});

  @override
  State<_FinishScreenWithAudio> createState() => _FinishScreenWithAudioState();
}

class _FinishScreenWithAudioState extends State<_FinishScreenWithAudio> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onAudioPlay());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/image/finish1.png', width: 300),
        const SizedBox(height: 40),
        const Text(
          'Congratulations!\nYou get what Pinyin is.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
