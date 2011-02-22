class DiceFactory
    
    constructor: ->
        this.diceClasses = []
        
    register: (diceClass) ->
        this.diceClasses.push(diceClass)

    createDie: (spec) ->
        dice = undefined
        for diceClass in this.diceClasses
            dice = diceClass.fromString(spec)
            return dice if dice
    
    createNumberOfDice: (spec) ->
        match = spec.match(/^\d+/)
        if match && match[0] != spec
            number = Number(match[0])
            spec = spec.slice(match[0].length)
        else
            number = 1
        
        dice = (this.createDie(spec) for i in [1..number])
        
    create: (spec) ->
        specs = spec.replace(/-/, "+-").split('+')
        dice = []
        for spec in specs
            dice.push(this.createDie(spec)) unless spec == ""
        return if dice.length == 1 then dice[0] else new window.DiceRoller.DiceSum(dice)            

window.DiceRoller.diceFactory = new DiceFactory()