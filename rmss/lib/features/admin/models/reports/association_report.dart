class ItemPair {
  final String item1Name;
  final String item2Name;
  final int frequency; // How many times they were bought together

  ItemPair({
    required this.item1Name,
    required this.item2Name,
    required this.frequency,
  });
}

class AssociationAlgorithmReport {
  final List<ItemPair> frequentlyBoughtTogether;

  AssociationAlgorithmReport({
    required this.frequentlyBoughtTogether,
  });
}
