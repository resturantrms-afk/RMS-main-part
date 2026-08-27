void main() {
  var colorValue = 0xFF00FF00;
  var hex = colorValue.toRadixString(16);
  print('Color 1: $hex, substring: ${hex.substring(2)}');
  
  var color2 = 0xFF000000;
  var hex2 = color2.toRadixString(16);
  print('Color 2: $hex2, substring: ${hex2.substring(2)}');
  
  var color3 = 0xFF050505;
  var hex3 = color3.toRadixString(16);
  print('Color 3: $hex3, substring: ${hex3.substring(2)}');
}
