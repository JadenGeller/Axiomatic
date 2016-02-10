# Axiomatic

Axiomatic is a logic framework that, give declarations of facts and rules, provides a mechanism to run a query to determine if a statement is true, and if so, under what conditions. Axiomatic is built on top of the unification framework [Gluey](https://github.com/JadenGeller/Gluey), and it extends it by defining tree-like unification types as well as a query system that is suitable for logic programming. Axiomatic is closely based off the logic programming language [Prolog](https://en.wikipedia.org/wiki/Prolog) as well as the mathematic concept of [Horn clauses](https://en.wikipedia.org/wiki/Horn_clause).

## Logic Programming

Rather then asking you to write a step-by-step algorithm to solve a problem, [logic programming](https://en.wikipedia.org/wiki/Logic_programming) asks you to provide a set of facts and rules. For example, we can starting by giving the fact that grass is green `color(grass, green)` and the rule that green things are awesome `awesome(X) :- color(X, green)`, and then query whether grass is in fact awesome, `?- awesome(grass)`. Note that the order of "grass" and "green" are unimportant as long as we are internally consistent. Logic programming doesn't just let us ask yes or no questions though, we can ask it for all possible solutions that fit our set of constraints.

Consider the following facts and rules (represented as a Prolog program):
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

## `Term`

Terms is the most primitive logic type provided by Axiomatic. Essentially, it allows you define both atoms, like `jaden` and `green`, as well as complex compound terms, such as `awesome(jaden)` or `triangle(point(0, 0), point(1, 1), point(0, 1))`. Terms consist of a `name` as well as 0 or more `arguments`. Though the name must be a literal value, the arguments may be variables. For example, `color(X, purple)` says that *everything* is purple!

```swift
let s = Term(name: "cool", arguments: [.Literal(Term(atom: "swift"))])  // cool(swift).
let p = Term(name: "cool", arguments: [.Literal(Term(atom: "prolog"))]) // cool(prolog).
```

Note that each argument of a `Term` is of type `Unifiable<Term>`, so you must specify if the argument is of the `Unifiable.Literal(Term)` or the `Unifiable.Variable(Binding)` case. As a reminder, a [`Binding`](https://github.com/jadengeller/gluey#binding) is a type defined by [Gluey](https://github.com/JadenGeller/Gluey) that can be unified with other instances of the same type. It is used to represent variables within this framework since they become bound together by the unification process and often two variables in seperate terms ought to refer to the same value.

## `Clause`

Clauses make statements of the form *X implies Y*. That *Y* is called the `head` of the clause, and it consists of a single term, while that *X* is called the `tail` of the clause, and it consists of a collection of terms that when true, imply the head is true. The special case in which the `tail` is empty is called a fact since it is unequivocally true. Otherwise, a clause is called a rule since the tail defines a sufficient condition upon which the head will be considered true.

As a reminder, a `Clause` is formed entirely of our of `Term`s. The clause `happy(monkey) :- eating(monkey, banana)` for example, says that the term `happy(monkey)` is true whenever the term `eating(monkey, banana)`. It doesn't however imply the converse since there might exist another clause that says the monkey is also happy if it's eating rope swinging.

Clauses can and often do utilize terms with variable arguments to specify conditional truths. This is done by declaring a [`Binding`](https://github.com/jadengeller/gluey#binding) and using it as a variable in one or more arguments in one or more terms of the clause. Note that it is illegal but unchecked to share the same `Binding` between multiple variables in separate clauses, and doing so will result in undefined behavior. 

```swift
// awesome(X) :- color(X, green).
let x = Binding<Term<String>>()
let c = Clause(
     rule: Term(name: "awesome", arguments: [
          .Variable(x)
     ]),
     conditions: [
          Term(name: "color", arguments: [
               .Variable(x),
               .Literal(Term(atom: "green"))
          ])
     ]
)
```

Now you're probably thinking, wow, that's a *really* wordy definition of such a simple Prolog query, and you're right. Axiomatic isn't intended to be used to build programs "out of the box", but rather it's intended to be used a base for programs that rely on logic. Further, it relatively easy and straightforward to provide an abstraction atop Axiomatic to make it suitable for specific use cases.

## `System`

Once you've defined clauses to your hearts desire, you're ready to finally do something with them. `System` provides an initializer that takes in a sequence of clauses and build a logic system that can be easily queried. Let's check out what our grandparent example from above looks like as an Axiomatic system!

```swift
let system = System(clauses: [
    // parent(matt, jaden).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Matt")),
        .Literal(Term(atom: "Jaden"))
    ])),
    // parent(tuesday, jaden).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Tuesday")),
        .Literal(Term(atom: "Jaden"))
    ])),
    // parent(debbie, matt).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Debbie")),
        .Literal(Term(atom: "Matt"))
    ])),
    // parent(dennis, matt).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Dennis")),
        .Literal(Term(atom: "Matt"))
    ])),
    // parent(liz, tuesday).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Liz")),
        .Literal(Term(atom: "Tuesday"))
    ])),
    // parent(mike, tuesday).
    Clause(fact: Term(name: "parent", arguments: [
        .Literal(Term(atom: "Mike")),
        .Literal(Term(atom: "Tuesday"))
    ])),
    // grandparent(A, B) :- parent(A, X), parent(X, B).
    Clause{ A, B, X in (
        rule: Term(name: "grandparent", arguments: [.Variable(A), .Variable(B)]),
        requirements: [
            Term(name: "parent", arguments: [.Variable(A), .Variable(X)]),
            Term(name: "parent", arguments: [.Variable(X), .Variable(B)])
        ]
    )}
])
```

Damn, that was long! Well, don't worry about that. As we said, syntactical consiseness was never a goal! So what did we just do? We defined a `System` of logical facts and rules that we can later query.

Notice that the initalizer for our grandparent rule took in a lambda? Well, Axiomatic defines these sorts of convenience initializer for `Clause` so you can define rules without having to seperately declare a `Binding`. Simply pass a lambda taking as many `Binding` arguments as you'd like (up to 6) into the initializer for `Clause`, and return the argument tuple it'd normally expect. If you're confused, no worries, this is just a syntactic convenience; you can still declare your bindings separately in the outer scope. 

So how do we *query* this system? Well, there's a fancy little function called `enumerateMatches` just for this!
```swift
let G = Binding<Term<String>>()
let query = Term(name: "grandparent", arguments: [.Variable(G), .Literal(Term(atom: "Jaden"))])
try system.enumerateMatches(query) {
    print(G) // -> Debbie -> Dennis -> Liz -> Mike
}
```
Ta-dah! Pretty simple, huh? Notice that we had to mark call that function with a `try`. This is because our query may fail to unify at all. Futhermore, you're not guarenteed that every `Binding` will have a non-`nil` value inside of the callback. If the logical system doesn't place sufficient restrictions on a variable, it may be possible for it to be unified without finding an actual concrete value.

By default, `enumerateMatches` will call the callback for each possible match. If you'd instead like to return after any given match, simply throw `SystemException.Break`, and the system will halt the unification process.

You are not guarenteed that the unified state of the variables will remain after you return from the callback. As such, make sure to record any information you might need to know while *inside* the callback.

## That's all folks!

Hopefully this was a good introduction to logic programming and the Axiomatic framework. If you find yourself still confused, dig through the [source code](https://github.com/JadenGeller/Axiomatic/tree/master/Sources) a bit, check out some of the [test cases](https://github.com/JadenGeller/Axiomatic/blob/master/Axiomatic/AxiomaticTests/SystemTests.swift), and maybe read the [documentation](http://jadengeller.github.io/Axiomatic/index.html). If you're still lost, feel free to [tweet me](https://twitter.com/jadengeller)! :)
