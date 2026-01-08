import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:masterhanyu_app/screens/tones_quiz_screen.dart';

class TonesScreen extends StatefulWidget {
  const TonesScreen({super.key});

  @override
  State<TonesScreen> createState() => _TonesScreenState();
}

class _TonesScreenState extends State<TonesScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPage = 0;

  // Tone data
  final List<ToneData> tones = [
    ToneData(
      title: "Four tones in Chinese",
      isOverview: true,
      description:
          " Mandarin Chinese is a tonal language. In order to differentiate meanings, the same syllable can be pronounced with different tones.\n\n Mandarin has four main tones and one neutral tone (a fifth tone according to some).",
    ),
    ToneData(
      title: "The first tone",
      tone: "ā",
      image: "assets/image/1st_tone.png",
      audioPath: "audio/tones/1st_ā.mp3",
      description:
          '''The first tone is high and flat, like in the English expression "ah".

It is represented by a straight horizontal line above a letter in Pinyin (or by the number "1" after the syllable).''',
    ),
    ToneData(
      title: "The second tone",
      tone: "á",
      image: "assets/image/2nd_tone.png",
      audioPath: "audio/tones/2nd_á.mp3",
      description:
          '''The second tone rises moderately. In English we sometimes associate this rise in pitch with a question, like "what?"

The second tone is represented by a rising diagonal line above a letter in Pinyin (or written by the number "2" after the syllable)''',
    ),
    ToneData(
      title: "The third tone",
      tone: "ǎ",
      image: "assets/image/3rd_tone.png",
      audioPath: "audio/tones/3rd_ǎ.mp3",
      description:
          '''The third tone falls and then rises again, like an interjection "well" in English.

It is represented by a curved "dipping" line above a letter in Pinyin (or sometimes by the number "3" after the syllable).''',
    ),
    ToneData(
      title: "The fourth tone",
      tone: "à",
      image: "assets/image/4th_tone.png",
      audioPath: "audio/tones/4th_à.mp3",
      description:
          '''The fourth tone starts out high but drops sharply to the bottom of the tonal range. English-speakers often associate this tone with an angry command, like "No!"

It is represented by a dropping diagonal line above a letter in Pinyin (or by the number "4" after the syllable).''',
    ),
    ToneData(
      title: "Neutral tone",
      tone: "a",
      audioPath: "audio/tones/a.mp3",
      description:
          "The neutral tone doesn't have any tone at all. It is pronounced quickly and lightly without regarding to pitch.\n\nSyllables with a neutral tone have no tone mark.",
    ),
    ToneData(isFinish: true, title: "", description: ""),
  ];

  Future<void> _playToneAudio(String audioPath) async {
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _nextPage() {
    if (_currentPage < tones.length - 2) {
      setState(() => _currentPage++);
    } else if (_currentPage == tones.length - 2) {
      // Allow going to finish screen
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTone = tones[_currentPage];
    final isFinish = currentTone.isFinish;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 160, 248),
        elevation: 0,
        title: const Text(
          "Tones",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Main scrollable content
          Expanded(
            child:
                isFinish
                    ? SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_buildFinishScreen()],
                      ),
                    )
                    : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              currentTone.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            // Overview content or Tone content
                            if (currentTone.isOverview) ...[
                              _buildOverviewContent(currentTone),
                            ] else ...[
                              _buildToneContent(currentTone),
                            ],
                          ],
                        ),
                      ),
                    ),
          ),

          // Navigation buttons at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child:
                isFinish
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _previousPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C56D6),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TonesQuizScreen(),
                              ),
                            );
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
                          child: const Text('GO'),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C56D6),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              _currentPage < tones.length - 1
                                  ? _nextPage
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C56D6),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishScreen() {
    return _FinishScreenWithAudio(
      onAudioPlay: () => _playToneAudio('audio/finish.mp3'),
    );
  }

  Widget _buildOverviewContent(ToneData tone) {
    return Column(
      children: [
        // Tone grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _toneGridItem("ā", "first tone"),
            _toneGridItem("á", "second tone"),
            _toneGridItem("ǎ", "third tone"),
            _toneGridItem("à", "fourth tone"),
          ],
        ),
        const SizedBox(height: 24),
        // Description
        Text(
          tone.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _toneGridItem(String tone, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tone,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildToneContent(ToneData tone) {
    final hasImage = tone.image != null;
    final hasAudio = tone.audioPath != null;
    final displayTone = tone.tone ?? '';

    return Column(
      children: [
        // Tone image (optional)
        if (hasImage) ...[
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(tone.image!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 28),
        ],

        // Clickable tone
        GestureDetector(
          onTap: hasAudio ? () => _playToneAudio(tone.audioPath!) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTone,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.volume_up, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Description
        Text(
          tone.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/image/finish1.png', width: 300),
        const SizedBox(height: 40),
        const Text(
          'Getting the hang of it?\nLet\'s do a practice.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}

class ToneData {
  final String title;
  final String? tone;
  final String? image;
  final String? audioPath;
  final String description;
  final bool isOverview;
  final bool isFinish;

  ToneData({
    required this.title,
    required this.description,
    this.tone,
    this.image,
    this.audioPath,
    this.isOverview = false,
    this.isFinish = false,
  });
}
