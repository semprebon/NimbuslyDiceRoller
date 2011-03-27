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
        if /max\((.*)\)/.test(spec)
            specs = spec[4..-2].split(',')
            dice = []
            for spec in specs
                dice.push(this.createDie(spec)) unless spec == ""
            return new window.DiceRoller.DicePickHighest(1, dice)
        else
            specs = spec.replace(/-/, "+-").split('+')
            dice = []
            for spec in specs
                dice.push(this.createDie(spec)) unless spec == ""
            return if dice.length == 1 then dice[0] else new window.DiceRoller.DiceSum(dice)

    createCombo: (spec) ->
        diceCombo = this.create(spec)
        if diceCombo instanceof window.DiceRoller.Die
            diceCombo = new window.DiceRoller.DiceSum([diceCombo])
        diceCombo
    
window.DiceRoller.diceFactory = new DiceFactory()

window.DiceRoller.diceFactory.itemFromAttributes = (attr) ->
    diceCombo = this.createCombo(attr.typeId)
    diceCombo.computeResult()
    diceCombo.key = attr.key
    diceCombo.title = attr.title
    unless diceCombo.dice.length == 0
        for i in [0..diceCombo.dice.length-1]
            diceCombo.dice[i].currentRoll = attr.rolls[i]
    diceCombo
