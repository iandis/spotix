enum SpotifyImageDimension {
  large,
  medium,
  small,
  extraSmall,
  thumbnail,
}

extension SpotifyImageDimensionValue on SpotifyImageDimension {
  static const List<int> _values = <int>[
    720,
    480,
    360,
    240,
    144,
  ];

  int get value => _values[index];
}
