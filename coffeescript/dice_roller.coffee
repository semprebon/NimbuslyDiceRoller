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
    constructor: (el_selector) ->
        this.element = jQuery(el_selector)
        this.dieSelector =  jQuery(jQuery(el_selector + ' .die')[0])
        this.wildCheckbox = jQuery(jQuery(el_selector + ' .wildcard')[0])
        this.rollResult = jQuery('#roll_result')
        this.dieSelector.change (event) => this.rollDice()
        this.wildCheckbox.change (event) => this.rollDice()
        
    rollDice: ->
        die = window.DiceRoller.SavageDie.fromString(this.dieSelector.val())
        if this.wildCheckbox[0].checked
            die = new window.DiceRoller.DicePickHighest(1, die, new window.DiceRoller.SavageDie(6))
        rollResult = die.rollDice()
        this.rollResult.empty()
        new DiceView(this.rollResult, rollResult)
    
window.DiceRoller.DiceRoller = DiceRoller