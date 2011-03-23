Probability = window.DiceRoller.Probability

class DiceCombination
    constructor: (dice) ->
        this.dice = dice
    
    roll: -> 
        die.roll() for die in this.dice
        this.currentRoll = this.computeResult()
    
    add: (die) -> new this.constructor(this.dice.concat([die]))

    remove: (dieToRemove) -> 
        newDice = []
        for die in this.dice
            newDice.push(die) unless die == dieToRemove
        new this.constructor(newDice)
    
    isEmpty: -> this.dice.length == 0
        
    toAttributes: ->
        rolls = (die.roll for die in this.dice)
        { typeId: this.typeId, rolls: rolls, key: this.key, title: this.title }
        
class DiceSum extends DiceCombination
    constructor: (dice) -> 
        super(dice)
        this.typeId = (die.typeId for die in dice).join('+')
        this.min = 0
        this.max = 0
        for die in dice
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
            
    probToRollOverWith: (dice, target) ->
        return dice[0].probToRollOver(target) if dice.length == 1
        first = dice[0]
        rest = dice[1..-1]

        min = Math.max(first.min, target - this.maxRollOn(rest))
        max = Math.min(first.max, target - this.minRollOn(rest))

        return Probability.NEVER unless first.inRange(min)
        return Probability.ALWAYS unless first.inRange(max)
        
        Probability.anyExclusive(first.probToRoll(roll).and(this.probToRollOverWith(rest, target - roll)) for roll in [min..max]).xor(
            first.probToRollOver(max))

    probToRoll: (target) -> this.probToRollOn(this.dice, target)
    
    probToRollOver: (target) -> this.probToRollOverWith(this.dice, target)

    probToBeat: (target) -> this.probToRollOverWith(this.dice, target-1)
    
    computeResult: ->
        total = 0
        for die in this.dice
            total = total + die.currentRoll
        this.currentRoll = total

# Dice representing dice pools where we pick the highest n dice from a pool
class DicePickHighest extends DiceCombination
    constructor: (numToPick, dice) ->
        this.numToPick = numToPick
        super(dice)
        this.typeId = "max(" + (die.typeId for die in dice).join(',') + ")"
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

    # Compute the probabilty that the n highest dice of dice will have the target value
    probToRollNHighestOn: (n, target, dice) ->
        return Probability.NEVER if n > dice.length
        first = dice[0]
        if dice.length == 1
            result = if (n == 1) then first.probToRoll(target) else first.probToRollUnder(target+1)
        else
            rest = dice[1..-1]
            result = Probability.anyExclusive([
                    first.probToRollUnder(target).and(this.probToRollNHighestOn(n, target, rest)),
                    first.probToRoll(target).and(this.probToRollNHighestOn(n-1, target, rest))
                ])
            console.log("(" + first.probToRollUnder(target).prob + 
                " && " + this.probToRollNHighestOn(n, target, rest).prob +
                ") xor (" + first.probToRoll(target).prob + 
                "  && " + this.probToRollNHighestOn(n-1, target, rest).prob + ")")
        console.log("p for " + n + " on " + dice.length + " = " + result.prob)
        return result

    probToBeat: (target) ->
        Probability.any(die.probToBeat(target) for die in this.dice)

    probToRoll: (target) -> 
        this.probToRollNHighestOn(this.numToPick, target, this.dice)
        
    computeResult: ->
        total = null
        for die in this.dice
            total = if total then Math.max(total, die.currentRoll) else die.currentRoll
        this.currentRoll = total

        
window.DiceRoller.DiceCombination = DiceCombination
window.DiceRoller.DiceSum = DiceSum
window.DiceRoller.DicePickHighest = DicePickHighest

window.computeOddsFor = (diceArray) ->
    targets = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    probabilities = (Probability.any(die.probToBeat(target) for die in diceArray) for target in targets)
    return (prob.prob for prob in probabilities)

