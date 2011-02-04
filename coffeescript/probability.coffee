class Probability
    constructor: (@prob) ->
        
    or: (q) -> this.not().and(q.not()).not()
    orExclusive: (q) -> new Probability(this.prob + q.prob)
    and: (q) ->  new Probability(this.prob * q.prob)
    not: -> new Probability(1.0 - this.prob)
    times: (n) -> new Probability(Math.pow(this.prob, n))
    
Probability.all = (probs) -> 
    p = new Probability(1.0)
    for prob in probs
        p = p.and(prob)
    p

Probability.any = (probs) -> this.all(prob.not() for prob in probs).not()

Probability.anyExclusive = (probs) -> 
    p = new Probability(0.0)
    for prob in probs
        p = p.orExclusive(prob)
    p

Probability.NEVER = new Probability(0.0)
Probability.ALWAYS = new Probability(1.0)

window.DiceRoller = {}
window.DiceRoller.Probability = Probability

    