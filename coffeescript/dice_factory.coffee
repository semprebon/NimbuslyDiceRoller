class DiceFactory
    
    constructor: ->
        @diceClasses = []
        
    register: (diceClass) ->
        @diceClasses.push(diceClass)

    createDie: (spec) ->
        dice = undefined
        for diceClass in @diceClasses
            dice = diceClass.fromString(spec)
            return dice if dice
    
    createNumberOfDice: (spec) ->
        match = spec.match(/^\d+/)
        if match && match[0] != spec
            number = Number(match[0])
            spec = spec.slice(match[0].length)
        else
            number = 1
        
        dice = (@createDie(spec) for i in [1..number])
        
    create2: (spec) ->
        if /max\((.*)\)/.test(spec)
            specs = spec.slice(4, -2).split(',')
            dice = []
            for spec in specs
                dice.push(@createDie(spec)) unless spec == ""
            return new window.DiceRoller.DicePickHighest(1, dice)
        else
            specs = spec.replace(/-/, "+-").split('+')
            dice = []
            for spec in specs
                dice.push(@createDie(spec)) unless spec == ""
            return if dice.length == 1 then dice[0] else new window.DiceRoller.DiceSum(dice)

    create: (spec) ->
        if /max\((.*)\)/.test(spec)
            specs = spec.slice(4, -1).split(',')
            dice = (@createDie(spec) for spec in specs when spec != "")
            return new window.DiceRoller.DicePickHighest(1, dice)
        else
            specs = spec.replace(/-/, "+-").split('+')
            dice = (@createDie(spec) for spec in specs when spec != "")
            return if dice.length == 1 then dice[0] else new window.DiceRoller.DiceSum(dice)

    createCombo: (spec) ->
        diceCombo = @create(spec)
        if diceCombo instanceof window.DiceRoller.Die
            diceCombo = new window.DiceRoller.DiceSum([diceCombo])
        diceCombo
    
window.DiceRoller.diceFactory = new DiceFactory()

window.DiceRoller.diceFactory.itemFromAttributes = (attr) ->
    diceCombo = @createCombo(attr.typeId)
    diceCombo.computeResult()
    diceCombo.key = attr.key
    diceCombo.title = attr.title
    unless diceCombo.dice.length == 0
        for i in [0...diceCombo.dice.length]
            diceCombo.dice[i].currentRoll = attr.rolls[i]
    diceCombo
