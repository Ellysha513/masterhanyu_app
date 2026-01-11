import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasicGreetingsScreen extends StatefulWidget {
  const BasicGreetingsScreen({super.key});

  @override
  State<BasicGreetingsScreen> createState() => _BasicGreetingsScreenState();
}

class _BasicGreetingsScreenState extends State<BasicGreetingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPage = 0;

  // Greeting data
  final List<GreetingData> greetings = [
    GreetingData(
      tone: "zǎo ān",
      image: "assets/image/zǎo_ān.png",
      audioPath: "audio/greetings/zǎo_ān.mp3",
      description: "Good morning - A polite greeting used in the morning. This greeting is typically used from 6:00am - 10:59am.",
    ),
    GreetingData(
      tone: "wǔ ān",
      image: "assets/image/wǔ_ān.png",
      audioPath: "audio/greetings/wǔ_ān.mp3",
      description: "Good afternoon - Used to greet someone in the afternoon.  This greeting is typically used from 12:00pm - 6:59pm.",
    ),
    GreetingData(
      tone: "wǎnshang hǎo",
      image: "assets/image/wǎnshang_hǎo.png",
      audioPath: "audio/greetings/wǎnshang_hǎo.mp3",
      description: "Good evening - A greeting used in the evening. This greeting is typically used from 7:00pm until it's time to go to bed.",
    ),
    GreetingData(
      tone: "wǎn' ān",
      image: "assets/image/wǎn_ān.png",
      audioPath: "audio/greetings/wǎn_ān.mp3",
      description:
          "Good night - Said before going to bed.",
    ),
    GreetingData(
      tone: "nǐhǎo",
      image: "assets/image/nǐhǎo.png",
      audioPath: "audio/greetings/nǐhǎo.mp3",
      description: "Hello - The most common greeting in Chinese.",
    ),
    GreetingData(
      tone: "wǒ jiào",
      image: "assets/image/wǒ_jiào.png",
      audioPath: "audio/greetings/wǒ_jiào.mp3",
      description: "My name is... - Used to introduce yourself.",
    ),
    GreetingData(
      tone: "wǒ shì",
      image: "assets/image/wǒ_shì.png",
      audioPath: "audio/greetings/wǒ_shì.mp3",
      description: "I am... - Another way to introduce yourself.",
    ),
    GreetingData(
      tone: "nǐhǎo ma",
      image: "assets/image/nǐhǎo_ma.png",
      audioPath: "audio/greetings/nǐhǎo_ma.mp3",
      description:
          "How are you? - A common question to ask someone's wellbeing.",
    ),
    GreetingData(
      tone: "wǒ hěn hǎo",
      image: "assets/image/wǒ_hěn_hǎo.png",
      audioPath: "audio/greetings/wǒ_hěn_hǎo.mp3",
      description: "I'm very well - A positive response to 'How are you?'",
    ),
    GreetingData(
      tone: "hǎojiǔ bújiàn",
      image: "assets/image/hǎojiǔ_bújiàn.png",
      audioPath: "audio/greetings/hǎojiǔ_bújiàn.mp3",
      description:
          "Long time no see - Said when meeting someone after a while.",
    ),
    GreetingData(
      tone: "zàijiàn",
      image: "assets/image/zàijiàn.png",
      audioPath: "audio/greetings/zàijiàn.mp3",
      description: "Goodbye - A common farewell greeting.",
    ),
    GreetingData(
      tone: "xièxie",
      image: "assets/image/xièxie.png",
      audioPath: "audio/greetings/xièxie.mp3",
      description: "Thank you - Used to express gratitude to someone.",
    ),
    GreetingData(
      tone: "bú kèqi",
      image: "assets/image/bú_kèqi.png",
      audioPath: "audio/greetings/bú_kèqi.mp3",
      description: "You're welcome - A polite response to 'thank you'.",
    ),
    GreetingData(
      tone: "duìbuqǐ",
      image: "assets/image/duìbuqǐ.png",
      audioPath: "audio/greetings/duìbuqǐ.mp3",
      description: "Sorry - Greeting used to apologize.",
    ),
    GreetingData(
      tone: "méi guānxi",
      image: "assets/image/méi_guānxi.png",
      audioPath: "audio/greetings/méi_guānxi.mp3",
      description: "No problem / It's okay - A response to an apology.",
    ),
    GreetingData(isFinish: true, tone: "", description: ""),
  ];

  Future<void> _playGreetingAudio(String audioPath) async {
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await prefs.setDouble('basic_greetings_progress_$userId', 1.0);
      }
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  void _nextPage() {
    if (_currentPage < greetings.length - 2) {
      setState(() => _currentPage++);
    } else if (_currentPage == greetings.length - 2) {
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
    final currentGreeting = greetings[_currentPage];
    final isFinish = currentGreeting.isFinish;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 160, 248),
        elevation: 0,
        title: const Text(
          "Greetings",
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
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [_buildGreetingContent(currentGreeting)],
                          ),
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
                          onPressed: () async {
                            await _saveProgress();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
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
                          child: const Text('FINISH'),
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
                              _currentPage < greetings.length - 1
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
      onAudioPlay: () => _playGreetingAudio('audio/finish.mp3'),
    );
  }

  Widget _buildGreetingContent(GreetingData greeting) {
    final hasImage = greeting.image != null;
    final hasAudio = greeting.audioPath != null;
    final displayTone = greeting.tone ?? '';

    return Column(
      children: [
        // Greeting image
        if (hasImage) ...[
          Container(
            height: 370,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(greeting.image!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 24),
        ],

        // Clickable greeting phrase
        GestureDetector(
          onTap:
              hasAudio ? () => _playGreetingAudio(greeting.audioPath!) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.volume_up, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Description
        Text(
          greeting.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
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
          'Great job!\nYou\'ve learned basic greetings.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}

class GreetingData {
  final String? tone;
  final String? image;
  final String? audioPath;
  final String description;
  final bool isFinish;

  GreetingData({
    required this.description,
    this.tone,
    this.image,
    this.audioPath,
    this.isFinish = false,
  });
}
