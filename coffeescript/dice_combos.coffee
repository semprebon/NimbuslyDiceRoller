Probability = window.DiceRoller.Probability

class DiceSum
    constructor: -> 
        this.dice = []
        for die in arguments
            this.dice.push(die)
    
    waysToRoll: (target) ->
        return [] unless target >= this.dice.length
        ([i, target-i] for i in [1..target-1])
    
    probToRollExactly: (targets) -> 
        Probability.all(this.dice[i].probToRoll(targets[i]) for i in [0..targets.length-1])
        
    maxRollOn: (dice) ->
        return dice[0].max if dice.length == 1
        dice[0].max + this.maximumRollOn(dice[1..-1])
        
    minRollOn: (dice) ->
        return dice[0].min if dice.length == 1
        dice[0].min + this.minimumRollOn(dice[1..-1])
        
    probToRollOn: (dice, target) ->
        return dice[0].probToRoll(target) if dice.length == 1
        die = dice[0]
        
        min = Math.max(die.min, target - this.maxRollOn(dice[1..-1]))
        max = Math.min(die.max, target - this.minRollOn(dice[1..-1]))
        return Probability.NEVER unless die.inRange(min) && die.inRange(max)
        
        Probability.anyExclusive(
            die.probToRoll(roll).and(this.probToRollOn(dice[1..-1], target - roll)) for roll in [min..max])
            
    probToRoll: (target) -> 
        this.probToRollOn(this.dice, target)

window.DiceRoller.DiceSum = DiceSum

window.computeOddsFor = (diceArray) ->
    targets = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    probabilities = (Probability.any(die.probToBeat(target) for die in diceArray) for target in targets)
    return (prob.prob for prob in probabilities)

