Probability = window.DiceRoller.Probability

class DiceSum
    constructor: -> 
        this.dice = []
        this.min = 0
        this.max = 0
        for die in arguments
            this.dice.push(die)
            this.min = this.min + die.min
            this.max = this.max + die.max
    
    waysToRoll: (target) ->
        return [] unless target >= this.dice.length
        ([i, target-i] for i in [1..target-1])
    
    probToRollExactly: (targets) -> 
        Probability.all(this.dice[i].probToRoll(targets[i]) for i in [0..targets.length-1])
        
    maxRollOn: (dice) ->
        return dice[0].max if dice.length == 1
        dice[0].max + this.maxRollOn(dice[1..-1])
        
    minRollOn: (dice) ->
        return dice[0].min if dice.length == 1
        dice[0].min + this.minRollOn(dice[1..-1])
        
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
    

class DicePickHighest
    constructor: (numToPick) ->
        this.numToPick = numToPick
        this.dice = []
        for die in arguments
            this.dice.push(die) unless die == numToPick
        this.min = this.minRollOn(this.dice)
        this.max = this.maxRollOn(this.dice)        

    probToRollExactly: (targets) -> 
        Probability.all(this.dice[i].probToRoll(targets[i]) for i in [0..targets.length-1])

    maxRollOn: () ->
        result = null
        for die in this.dice
            result = Math.max(result, die.max)
        return result

    minRollOn: () ->
        result = null
        for die in this.dice
            result = Math.max(result, die.min)
        return result

    probToRollUnderOn: (dice, target) -> this.probToBeatOn(dice, target).not()
        
    probToBeatOn: (dice, target) ->
        return dice[0].probToBeat(target) if dice.length == 1
        dice[0].probToBeat(target).or(this.probToBeatOn(dice[1..-1], target))
        
    probToRollOn: (dice, target) ->
        console.log("prob to roll " + target + " on " + dice[0].typeId + ' is ' + dice[0].probToRoll(target).prob)
        return dice[0].probToRoll(target) if dice.length == 1
        p1 = dice[0].probToRoll(target).and(this.probToRollUnderOn(dice[1..-1], target+1))
        p2 = this.probToRollUnderOn(dice[0..0], target).and(this.probToRollOn(dice[1..-1], target))
        p1.orExclusive(p2)

    probToBeat: (target) ->
        Probability.any(die.probToBeat(target) for die in this.dice)

    probToRoll: (target) -> 
        new Probability(this.probToBeat(target).prob - this.probToBeat(target+1).prob)


window.DiceRoller.DiceSum = DiceSum
window.DiceRoller.DicePickHighest = DicePickHighest

window.computeOddsFor = (diceArray) ->
    targets = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    probabilities = (Probability.any(die.probToBeat(target) for die in diceArray) for target in targets)
    return (prob.prob for prob in probabilities)

