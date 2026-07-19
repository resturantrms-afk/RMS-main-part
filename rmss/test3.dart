class A { dynamic cat; A(this.cat); } void main() { List<A> items = [A('hello')]; items.expand((i) => i.cat).toList(); }
