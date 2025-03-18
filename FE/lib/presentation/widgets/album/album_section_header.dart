import 'package:flutter/material.dart';

class AlbumSectionHeader extends StatelessWidget {
  final String title;
  final String currentGenre;
  final List<String> genres;
  final ValueChanged<String> onGenreSelected;

  const AlbumSectionHeader({
    Key? key,
    required this.title,
    required this.currentGenre,
    required this.genres,
    required this.onGenreSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    genres.map((genre) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Theme(
                          data: ThemeData(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: ChoiceChip(
                            label: Text(
                              genre,
                              style: const TextStyle(color: Colors.white),
                            ),
                            selected: currentGenre == genre,
                            showCheckmark: false,
                            selectedColor: const Color(0xFFD9D9D9),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (bool selected) {
                              onGenreSelected(genre);
                            },
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
