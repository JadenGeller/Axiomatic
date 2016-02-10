# Axiomatic

Axiomatic is a logic framework that, give declarations of facts and rules, provides a mechanism to run a query to determine if a statement is true, and if so, under what conditions. Axiomatic is built on top of the unification framework [Gluey](https://github.com/JadenGeller/Gluey), and it extends it by defining tree-like unification types and a query system that is suitable for logic programming. Axiomatic is closely based off the logic programming language [Prolog](https://en.wikipedia.org/wiki/Prolog) as well as the mathematic concept of [Horn clauses](https://en.wikipedia.org/wiki/Horn_clause).

An example:
```swift
let system = System(clauses: [
     // male(jaden).
     Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "jaden"))])),
     // male(matt).
     Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "matt"))])),
     // female(tuesday).
     Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "tuesday"))])),
     // female(kiley).
     Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "kiley"))])),
     // father(Parent, Child) :- male(Parent), parent(Parent, Child).
     Clause{ parent, child in (
         rule: Predicate(name: "father", arguments: [.Variable(parent), .Variable(child)]),
         requirements: [
             Predicate(name: "male", arguments: [.Variable(parent)]),
             Predicate(name: "parent", arguments: [.Variable(parent), .Variable(child)])
         ]
     ) },
     // parent(tuesday, jaden).
     Clause(fact: Predicate(name: "parent", arguments:
         [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "jaden"))])),
     // parent(matt, jaden).
     Clause(fact: Predicate(name: "parent", arguments:
         [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "jaden"))])),
     // parent(matt, kiley).
     Clause(fact: Predicate(name: "parent", arguments:
         [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "kiley"))])),
     // parent(tuesday, kiley).
     Clause(fact: Predicate(name: "parent", arguments:
         [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "kiley"))]))
])
        
var results: [String] = []
let Child = Binding<Predicate<String>>()
// father(matt, Child).
try! system.enumerateMatches(Predicate(name: "father", arguments: [.Constant(Predicate(atom: "matt")), .Variable(Child)])) {
    results.append(Child.value!.name)
}
XCTAssertEqual(["jaden", "kiley"], results)
```

Check out more examples [here](https://github.com/JadenGeller/Axiomatic/blob/master/Axiomatic/AxiomaticTests/SystemTests.swift)! And read documentation [here](http://jadengeller.github.io/Axiomatic/docs/index.html).

More comprehensive README coming soon!
