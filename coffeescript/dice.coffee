
Probability = window.DiceRoller.Probability

# Generate a random integer between 0 and max-1
randomInt = (limit) -> Math.floor(Math.random() * limit)

# Base class for die classes. This sets up a basic flat-distribution dice
class Die
    constructor: (@min, @max) ->
        this.size = (this.max - this.min) + 1
        this.baseProbability = new Probability(1.0 / this.size)
        
    inRange: (target) -> this.min <= target && target <= this.max

    roll: -> Math.randomInt(this.size + 1) + this.min

    probToRoll: (target) -> if this.inRange(target) then this.baseProbability else Probability.NEVER
    
    probToBeat: (target) -> 
        return Probability.ALWAYS if target <= this.min
        return Probability.NEVER if target > this.max
        return new Probability((this.size - (target - this.min)) / this.size)
        

# A simple die - randomly generates a number between 1 and size
class SimpleDie extends Die

    constructor: (size) ->
        super(1, this.size)
        this.typeId = "d" + this.size
    
SimpleDie.fromString = (s) -> 
    return new SimpleDie(Number(id.slice(1))) if /^d\d+$/.test(s)
    return null

# Fudge Dice - random number from -1 to +1
class FudgeDie extends Die

    constructor: () ->
        super(-1, +1)
        this.typeId = "dF"

FudgeDie.fromString = (s) ->
    return new FudgeDie() if s == "dF"
    return null
    
# Fixed Adjustment
class Adjustment extends Die

    constructor: (value) ->
        super(value, value)
        this.typeId = "+" + value

Adjustment.fromString = (s) ->
    return new Adjustment(Number(s)) if /^[+\-]?\d+$/.test(s)
    return null

# Savage Worlds exploding dice - on rolling max value, roll again and add
class SavageDie extends Die

    constuctor: (size) ->
        this.size = size
        this.max = Infinity
        this.value = value || 1
        this.typeId = "s" + size
        
    roll: ->
        roll = super()
        total = roll
        while (roll == this.size)
            roll = super()
            total += roll
        total

    probToRoll: (target) -> 
        return this.baseProbability if target < this.sides
        return Probability.NEVER if target == this.sides
        this.baseProbability.and(this.probToRoll(target - 6))
        
    probToBeat: (target) ->
        return super(target) if target <= this.sides
        this.baseProbability.and(this.probToBeat(target - 6))

SavageDie.fromString = (s) -> 
    return new SavageDie(Number(s.slice(1))) if /^s\d+$/.test(s)
    return null

window.DiceRoller.Die = Die
window.DiceRoller.SimpleDie = SimpleDie
window.DiceRoller.FudgeDie = FudgeDie
window.DiceRoller.SavageDie = SavageDie
window.DiceRoller.Adjustment = Adjustment

