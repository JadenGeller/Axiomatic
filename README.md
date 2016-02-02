# Axiomatic

Axiomatic, built on top of [Gluey](https://github.com/JadenGeller/Gluey), defines tree-like unification types suitable for logic programming.

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

Check out more examples [here](https://github.com/JadenGeller/Axiomatic/blob/master/Axiomatic/AxiomaticTests/SystemTests.swift)!

More comprehensive README coming soon!
