# Axiomatic

Axiomatic is a logic framework that, give declarations of facts and rules, provides a mechanism to run a query to determine if a statement is true, and if so, under what conditions. Axiomatic is built on top of the unification framework [Gluey](https://github.com/JadenGeller/Gluey), and it extends it by defining tree-like unification types as well as a query system that is suitable for logic programming. Axiomatic is closely based off the logic programming language [Prolog](https://en.wikipedia.org/wiki/Prolog) as well as the mathematic concept of [Horn clauses](https://en.wikipedia.org/wiki/Horn_clause).

## Logic Programming

Rather then asking you to write a step-by-step algorithm to solve a problem, [logic programming](https://en.wikipedia.org/wiki/Logic_programming) asks you to provide a set of facts and rules. For example, we can starting by giving the fact that grass is green `color(grass, green)` and the rule that green things are awesome `awesome(X) :- color(X, green)`, and then query whether grass is in fact awesome, `?- awesome(grass)`. Note that the order of "grass" and "green" are unimportant as long as we are internally consistent. Logic programming doesn't just let us ask yes or no questions though, we can ask it for all possible solutions that fit our set of constraints.

Consider the following facts and rules:
```prolog
parent(matt, jaden).
parent(tuesday, jaden).
parent(debbie, matt).
parent(dennis, matt).
parent(liz, tuesday).
parent(mike, tuesday).

grandparent(A, B) :- parent(A, X), parent(X, B).
```
We can easily query to find out who is the grandparent of Jaden, `?- grandparent(G, jaden)`, and with the response that `G` is either Debbie, Dennis, Liz, or Mike, as we'd expected.

Logic programming provides a really simple mechanism to find answers that can be easily deduced from a set of rules. There's no need to worry about enumerating all possible matches or even backtracking yourself as the framework handles it all.

## Term

`Term` is the most basic logic programming type provided by Axiomatic. Essentially, it allows you define both atoms, like `jaden` and `green`, as well as complex compound terms, such as `awesome(jaden)` or `triangle(point(0, 0), point(1, 1), point(0, 1))`. Terms consist of a name as well as 0 or more arguments. Though the name must be a literal value, the arguments may be variables. For example, `color(X, purple)` says that *everything* is purple!

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
