import 'package:flutter/material.dart';

class AllMantrasPage extends StatelessWidget {
  const AllMantrasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of 10 mantras
    final List<Map<String, String>> mantras = [
      {
        'name': 'Gayatri Mantra',
        'mantra': 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
        'meaning': 'The Gayatri Mantra is a highly revered mantra from the Rig Veda, dedicated to Savitri, the deity of the five elements.',
        'benefits': 'Enhances wisdom, improves concentration, purifies mind and soul. Brings spiritual awakening and removes negative energies.',
        'icon': '🕉️',
        'color': 'FF6B6B',
      },
      {
        'name': 'Shiv Mantra',
        'mantra': 'ॐ नमः शिवाय',
        'meaning': 'Salutations to Lord Shiva, the auspicious one. The destroyer of evil and transformer of the universe.',
        'benefits': 'Removes obstacles, brings peace, destroys negativity. Protects from dangers and grants liberation.',
        'icon': '🙏',
        'color': '4ECDC4',
      },
      {
        'name': 'Vishnu Mantra',
        'mantra': 'ॐ नमो भगवते वासुदेवाय',
        'meaning': 'Salutations to Lord Vasudeva (Krishna), the son of Vasudeva, the preserver of the universe.',
        'benefits': 'Brings prosperity, protection, and spiritual growth. Ensures harmony and removes fear.',
        'icon': '🌟',
        'color': '45B7D1',
      },
      {
        'name': 'Hanuman Mantra',
        'mantra': 'ॐ हं हनुमते नमः',
        'meaning': 'Salutations to Hanuman, the divine monkey god, symbol of strength and devotion.',
        'benefits': 'Gives strength, courage, and removes fear. Protects from evil spirits and negative forces.',
        'icon': '🐒',
        'color': 'FFA62E',
      },
      {
        'name': 'Durga Mantra',
        'mantra': 'ॐ एं ह्रीं क्लीं चामुण्डायै विच्चे',
        'meaning': 'Salutations to Goddess Chamunda, a form of Durga, the invincible protector.',
        'benefits': 'Protection from evil, success in endeavors. Destroys enemies and grants victory.',
        'icon': '👑',
        'color': 'FF6B8B',
      },
      {
        'name': 'Ganesh Mantra',
        'mantra': 'ॐ गं गणपतये नमः',
        'meaning': 'Salutations to Lord Ganesha, the remover of obstacles, god of wisdom and beginnings.',
        'benefits': 'Removes obstacles, brings success, improves intellect. Ensures smooth beginnings.',
        'icon': '🐘',
        'color': '95E1D3',
      },
      {
        'name': 'Saraswati Mantra',
        'mantra': 'ॐ ऐं सरस्वत्यै नमः',
        'meaning': 'Salutations to Goddess Saraswati, the goddess of knowledge, music, arts and wisdom.',
        'benefits': 'Enhances learning, memory, and creative skills. Brings clarity and eloquence.',
        'icon': '🎵',
        'color': 'A8E6CF',
      },
      {
        'name': 'Krishna Mantra',
        'mantra': 'ॐ क्लीं कृष्णाय नमः',
        'meaning': 'Salutations to Lord Krishna, the supreme personality, embodiment of love and compassion.',
        'benefits': 'Brings love, devotion, and spiritual enlightenment. Removes sorrow and grants bliss.',
        'icon': '🪕',
        'color': '9B5DE5',
      },
      {
        'name': 'Rama Mantra',
        'mantra': 'श्री राम जय राम जय जय राम',
        'meaning': 'Victory to Lord Rama, the ideal man, embodiment of righteousness and truth.',
        'benefits': 'Brings peace, harmony, and righteousness. Protects from difficulties and grants courage.',
        'icon': '🏹',
        'color': '00BBF9',
      },
      {
        'name': 'Mahamrityunjaya Mantra',
        'mantra': 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्',
        'meaning': 'We worship the three-eyed Lord Shiva who is fragrant and nourishes all beings.',
        'benefits': 'Conquers fear of death, promotes longevity and healing. Grants victory over death.',
        'icon': '💎',
        'color': '00F5D4',
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Divine Mantras',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFF4ECDC4),
                      Color(0xFF45B7D1),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),

          // Header text
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sacred Chants for Spiritual Growth',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Discover the power of ancient mantras that transform your consciousness',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Mantras Grid
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Adjusted for better fit
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final mantra = mantras[index];
                  final color = Color(int.parse('0xFF${mantra['color']}'));
                  final mantraText = mantra['mantra']!;
                  // Safe substring - check length first
                  final previewText = mantraText.length > 15
                      ? '${mantraText.substring(0, 15)}...'
                      : mantraText;

                  return GestureDetector(
                    onTap: () {
                      _showMantraDetails(context, mantra, index + 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.9),
                            color.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Content
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      mantra['icon']!,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 8),

                                // Mantra Name
                                Text(
                                  mantra['name']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 4),

                                // Mantra Preview
                                Expanded(
                                  child: Text(
                                    previewText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Number and arrow
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: mantras.length,
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 20, 16, 30),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B).withOpacity(0.1),
                    Color(0xFF4ECDC4).withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.spa,
                    size: 32,
                    color: Color(0xFF4ECDC4),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ॐ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chant with devotion and purity of heart',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMantraDetails(BuildContext context, Map<String, String> mantra, int number) {
    final color = Color(int.parse('0xFF${mantra['color']}'));
    // Track favorite state for each mantra
    bool isFavorite = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.95),
                    color.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header with icon and number
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              mantra['icon']!,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Mantra #$number',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                mantra['name']!,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mantra Card
                          _buildDetailCard(
                            title: 'The Sacred Chant',
                            content: mantra['mantra']!,
                            icon: Icons.volume_up,
                            bgColor: Colors.white.withOpacity(0.15),
                            textColor: Colors.white,
                            isMantra: true,
                          ),

                          SizedBox(height: 16),

                          // Meaning Card
                          _buildDetailCard(
                            title: 'Spiritual Meaning',
                            content: mantra['meaning']!,
                            icon: Icons.lightbulb_outline,
                            bgColor: Colors.white.withOpacity(0.15),
                            textColor: Colors.white,
                          ),

                          SizedBox(height: 16),

                          // Benefits Card
                          _buildDetailCard(
                            title: 'Divine Benefits',
                            content: mantra['benefits']!,
                            icon: Icons.health_and_safety,
                            bgColor: Colors.white.withOpacity(0.15),
                            textColor: Colors.white,
                          ),

                          SizedBox(height: 16),

                          // Chanting Tips
                          _buildDetailCard(
                            title: 'How to Chant',
                            content: '• Chant with devotion and purity of heart\n• Best during sunrise or sunset\n• Face East direction\n• Use Rudraksha or Tulsi mala\n• Maintain regular timing',
                            icon: Icons.tips_and_updates,
                            bgColor: Colors.white.withOpacity(0.15),
                            textColor: Colors.white,
                          ),

                          SizedBox(height: 25),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.list_alt, size: 16),
                                  label: Text('Add To List'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: color,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),

                              // Heart/Favorite Button
                              Container(
                                width: 50,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                      // Show a snackbar message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFavorite
                                                ? '${mantra['name']} saved to favorites ❤️'
                                                : '${mantra['name']} removed from favorites',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          backgroundColor: isFavorite ? Colors.red.shade600 : color,
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFavorite ? Colors.red.shade600 : Colors.white.withOpacity(0.3),
                                    foregroundColor: isFavorite ? Colors.white : Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: isFavorite ? BorderSide.none : BorderSide(color: Colors.white),
                                    ),
                                    elevation: isFavorite ? 3 : 0,
                                  ),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 22,
                                    color: isFavorite ? Colors.white : Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),

                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.volume_up, size: 16),
                                  label: Text('Listen'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color.withOpacity(0.3),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    bool isMantra = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor.withOpacity(0.8), size: 18),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: isMantra ? 16 : 14,
              color: textColor.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: isMantra ? TextAlign.center : TextAlign.left,
          ),
        ],
      ),
    );
  }
}