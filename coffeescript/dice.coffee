
Probability = window.DiceRoller.Probability

# Generate a random integer between 0 and max-1
randomInt = (limit) -> Math.floor(Math.random() * limit)

# Base class for die classes. This sets up a basic flat-distribution dice
class Die
    constructor: (@min, @max) ->
        @size = (@max - @min) + 1
        @baseProbability = new Probability(1.0 / @size)
        @roll()
        
    inRange: (target) -> @min <= target <= @max

    newRollValue: -> randomInt(@size) + @min
    
    roll: -> @currentRoll = @newRollValue()
    
    probToRoll: (target) -> if @inRange(target) then @baseProbability else Probability.NEVER
    
    probToBeat: (target) -> 
        return Probability.ALWAYS if target <= @min
        return Probability.NEVER if target > @max
        return new Probability((@size - (target - @min)) / @size)

    probToRollOver: (target) -> @probToBeat(target+1)
        
    probToRollUnder: (target) -> @probToBeat(target).not()
    
    toAttributes: ->
        { typeId: @typeId, rolls: [@currentRoll], key: @key, title: @title }

# A simple die - randomly generates a number between 1 and size
class SimpleDie extends Die

    constructor: (size) ->
        super(1, size)
        @typeId = "d" + @size
    
SimpleDie.fromString = (s) -> 
    return new SimpleDie(Number(s.slice(1))) if /^d\d+$/.test(s)
    return null

# Fudge Dice - random number from -1 to +1
class FudgeDie extends Die

    constructor: () ->
        super(-1, +1)
        @typeId = "dF"

FudgeDie.fromString = (s) ->
    return new FudgeDie() if s == "dF"
    return null
    
# Fixed Adjustment
class Adjustment extends Die

    constructor: (value) ->
        super(value, value)
        @typeId = if value < 0 then "" + value else "+" + value

Adjustment.fromString = (s) ->
    return new Adjustment(Number(s)) if /^[+\-]?\d+$/.test(s)
    return null

# Savage Worlds exploding dice - on rolling max value, roll again and add
class SavageDie extends Die

    constructor: (size) ->
        super(1, size)
        @size = size
        @max = Infinity
        @typeId = "s" + size
        
    newRollValue: ->
        roll = super()
        total = roll
        while (roll == @size)
            roll = super()
            total += roll
        total
        
    probToRoll: (target) -> 
        return @baseProbability if target < @size
        return Probability.NEVER if target == @size
        @baseProbability.and(@probToRoll(target - @size))
        
    probToBeat: (target) ->
        return super(target) if target <= @size
        @baseProbability.and(@probToBeat(target - @size))

SavageDie.fromString = (s) -> 
    return new SavageDie(Number(s.slice(1))) if /^s\d+$/.test(s)
    return null

window.DiceRoller.Die = Die

window.DiceRoller.SimpleDie = SimpleDie
window.DiceRoller.diceFactory.register(SimpleDie)

window.DiceRoller.FudgeDie = FudgeDie
window.DiceRoller.diceFactory.register(FudgeDie)

window.DiceRoller.SavageDie = SavageDie
window.DiceRoller.diceFactory.register(SavageDie)

window.DiceRoller.Adjustment = Adjustment
window.DiceRoller.diceFactory.register(Adjustment)

