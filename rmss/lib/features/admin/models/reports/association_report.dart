class ItemSet {
  final List<String> items;
  final int frequency; // How many times they were bought together

  ItemSet({
    required this.items,
    required this.frequency,
  });
}

class AssociationAlgorithmReport {
  final List<ItemSet> frequentlyBoughtTogether;

  AssociationAlgorithmReport({
    required this.frequentlyBoughtTogether,
  });
}
