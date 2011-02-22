class DieView
    constructor: (parent, die, roll) ->
        this.die = die
        this.roll = roll
        this.typeId = die.typeId
        this.id = 'die_view_' + Math.floor(Math.random()*100000) 
        parent.append(tmpl('die_view_template', this))
        
class DiceView
    constructor: (parent, result) -> 
        this.diceViews = []
        for i in [0..result.dice.length-1]
            dieResult = result.rolls[i]
            dieResult = dieResult.result if dieResult.hasOwnProperty('result')
            this.diceViews.push(new DieView(parent, result.dice[i], dieResult))

class DiceRoller
    constructor: (pane_selector) ->
        this.element = jQuery(pane_selector)
        jQuery(".dice_set_pick").click (event) =>
            newSpec = jQuery(event.target).attr('spec')
            this.setDiceTo(newSpec) if newSpec 
            this.rollDice()
        this.rollArea = jQuery('.roll_area')

    setDiceTo: (spec) ->
        this.dice = window.DiceRoller.diceFactory.create(spec)
        
        
    rollDice: ->
        rollResult = this.dice.rollDice()
        this.rollArea.empty()
        new DiceView(this.rollArea, rollResult)
        jQuery(".roll_result").text(rollResult.result)
    
window.DiceRoller.DiceRoller = DiceRoller