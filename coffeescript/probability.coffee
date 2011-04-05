class Probability
    constructor: (@prob) ->
        
    or: (q) -> @not().and(q.not()).not()
    xor: (q) -> new Probability(@prob + q.prob)
    and: (q) ->  new Probability(@prob * q.prob)
    not: -> new Probability(1.0 - @prob)
    times: (n) -> new Probability(Math.pow(@prob, n))
    
Probability.all = (probs) -> 
    p = new Probability(1.0)
    for prob in probs
        p = p.and(prob)
    p

Probability.any = (probs) -> @all(prob.not() for prob in probs).not()

Probability.anyExclusive = (probs) -> 
    p = new Probability(0.0)
    for prob in probs
        p = p.xor(prob)
    p

Probability.NEVER = new Probability(0.0)
Probability.ALWAYS = new Probability(1.0)

window.DiceRoller = {}
window.DiceRoller.Probability = Probability

    