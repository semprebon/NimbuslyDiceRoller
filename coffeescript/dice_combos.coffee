Probability = window.DiceRoller.Probability

class DiceCombination
    constructor: (dice) ->
        @dice = dice
    
    roll: -> 
        die.roll() for die in @dice
        @currentRoll = @computeResult()
    
    add: (die) -> new @constructor(@dice.concat([die]))

    remove: (dieToRemove) -> 
        newDice = []
        for die in @dice
            newDice.push(die) unless die == dieToRemove
        new @constructor(newDice)
    
    isEmpty: -> @dice.length == 0
        
    toAttributes: ->
        rolls = (die.currentRoll for die in @dice)
        { typeId: @typeId, rolls: rolls, key: @key, title: @title }
        
class DiceSum extends DiceCombination
    constructor: (dice) -> 
        super(dice)
        @typeId = (die.typeId for die in dice).join('+')
        @min = 0
        @max = 0
        for die in dice
            @min = @min + die.min
            @max = @max + die.max
    
    waysToRoll: (target) ->
        return [] unless target >= @dice.length
        ([i, target-i] for i in [1..target-1])
    
    probToRollExactly: (targets) -> 
        Probability.all(@dice[i].probToRoll(targets[i]) for i in [0..targets.length-1])
        
    maxRollOn: (dice) ->
        return dice[0].max if dice.length == 1
        dice[0].max + @maxRollOn(dice[1..-1])
        
    minRollOn: (dice) ->
        return dice[0].min if dice.length == 1
        dice[0].min + @minRollOn(dice[1..-1])
        
    probToRollOn: (dice, target) ->
        return dice[0].probToRoll(target) if dice.length == 1
        die = dice[0]
        rest = dice.slice(1)
        
        min = Math.max(die.min, target - @maxRollOn(rest))
        max = Math.min(die.max, target - @minRollOn(rest))
        return Probability.NEVER unless die.inRange(min) && die.inRange(max)
        
        Probability.anyExclusive(
            die.probToRoll(roll).and(@probToRollOn(rest, target - roll)) for roll in [min..max])
            
    probToRollOverWith: (dice, target) ->
        return dice[0].probToRollOver(target) if dice.length == 1
        first = dice[0]
        rest = dice.slice(1)

        min = Math.max(first.min, target - @maxRollOn(rest))
        max = Math.min(first.max, target - @minRollOn(rest))

        return Probability.NEVER unless first.inRange(min)
        return Probability.ALWAYS unless first.inRange(max)
        
        Probability.anyExclusive(first.probToRoll(roll).and(@probToRollOverWith(rest, target - roll)) for roll in [min..max]).xor(
            first.probToRollOver(max))

    probToRoll: (target) -> @probToRollOn(@dice, target)
    
    probToRollOver: (target) -> @probToRollOverWith(@dice, target)

    probToBeat: (target) -> @probToRollOverWith(@dice, target-1)
    
    computeResult: ->
        total = 0
        for die in @dice
            total = total + die.currentRoll
        @currentRoll = total

# Dice representing dice pools where we pick the highest n dice from a pool
class DicePickHighest extends DiceCombination
    constructor: (numToPick, dice) ->
        @numToPick = numToPick
        super(dice)
        @typeId = "max(" + (die.typeId for die in dice).join(',') + ")"
        @min = @minRollOn(@dice)
        @max = @maxRollOn(@dice)        

    probToRollExactly: (targets) -> 
        Probability.all(@dice[i].probToRoll(targets[i]) for i in [0...targets.length])

    maxRollOn: () ->
        result = null
        for die in @dice
            result = Math.max(result, die.max)
        return result

    minRollOn: () ->
        result = null
        for die in @dice
            result = Math.max(result, die.min)
        return result

    # Compute the probabilty that the n highest dice of dice will have the target value
    probToRollNHighestOn: (n, target, dice) ->
        return Probability.NEVER if n > dice.length
        first = dice[0]
        if dice.length == 1
            result = if (n == 1) then first.probToRoll(target) else first.probToRollUnder(target+1)
        else
            rest = dice.slice(1)
            result = Probability.anyExclusive([
                    first.probToRollUnder(target).and(@probToRollNHighestOn(n, target, rest)),
                    first.probToRoll(target).and(@probToRollNHighestOn(n-1, target, rest))
                ])
        return result

    probToBeat: (target) ->
        Probability.any(die.probToBeat(target) for die in @dice)

    probToRoll: (target) -> 
        @probToRollNHighestOn(@numToPick, target, @dice)
        
    computeResult: ->
        total = null
        for die in @dice
            total = if total then Math.max(total, die.currentRoll) else die.currentRoll
        @currentRoll = total

        
window.DiceRoller.DiceCombination = DiceCombination
window.DiceRoller.DiceSum = DiceSum
window.DiceRoller.DicePickHighest = DicePickHighest

window.computeOddsFor = (diceArray) ->
    targets = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    probabilities = (Probability.any(die.probToBeat(target) for die in diceArray) for target in targets)
    return (prob.prob for prob in probabilities)

