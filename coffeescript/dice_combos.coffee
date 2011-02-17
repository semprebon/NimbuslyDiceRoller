Probability = window.DiceRoller.Probability

class DiceCombination
    
    roll: -> this.rollDice().result

    rollDice: ->
        rolls = (die.rollDice() for die in this.dice)
        { result: null, rolls: rolls, dice: this.dice }
    
class DiceSum extends DiceCombination
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
    
    rollDice: ->
        result = super()
        total = 0
        for roll in result.rolls
            total = total + roll.result
        result.result = total
        result


class DicePickHighest extends DiceCombination
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

    probToBeat: (target) ->
        Probability.any(die.probToBeat(target) for die in this.dice)

    probToRoll: (target) -> 
        new Probability(this.probToBeat(target).prob - this.probToBeat(target+1).prob)
        
    rollDice: ->
        result = super()
        total = null
        for roll in result.rolls
            total = Math.max(total, roll.result)
        result.result = total
        result

window.DiceRoller.DiceSum = DiceSum
window.DiceRoller.DicePickHighest = DicePickHighest

window.computeOddsFor = (diceArray) ->
    targets = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    probabilities = (Probability.any(die.probToBeat(target) for die in diceArray) for target in targets)
    return (prob.prob for prob in probabilities)

