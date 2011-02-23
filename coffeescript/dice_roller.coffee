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
        this.rollArea = jQuery('.roll_area')
        this.setUpDiceSelection()
        this.setUpQuickPicks()

    setDiceTo: (spec) ->
        this.dice = window.DiceRoller.diceFactory.create(spec)
        
        
    rollDice: ->
        rollResult = this.dice.rollDice()
        this.rollArea.empty()
        new DiceView(this.rollArea, rollResult)
        jQuery(".roll_result").text(rollResult.result)
    
    DICE_SPECS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF','+1','-1']
    QUICK_PICKS = [
        ['extra d4','s4'],
        ['extra d6','s6'],
        ['extra d8','s8'],
        ['extra d10','s10'],
        ['extra d12','s12'],
        ['wildcard d4','max(s4,s6)'],
        ['wildcard d6','max(s6,s6)'],
        ['wildcard d8','max(s8,s6)'],
        ['wildcard d10','max(s10,s6)'],
        ['wildcard d12','max(s12,s6)']]
        
    setUpQuickPicks: ->
        diceSelectionArea = jQuery('.quick_picks')
        for pick in QUICK_PICKS
            diceSelectionArea.append(tmpl('dice_set_view_template', { spec: pick[1], name: pick[0] }))
        jQuery(".dice_set_pick").click (event) =>
            newSpec = jQuery(event.target).attr('spec')
            this.setDiceTo(newSpec) if newSpec 
            this.rollDice()
        
        
    setUpDiceSelection: ->
        diceSelectionArea = jQuery('#diceSelection')
        for dieSpec in DICE_SPECS
            die = window.DiceRoller.diceFactory.create(dieSpec)
            diceSelectionArea.append(tmpl('die_view_select_template', die))
        jQuery('.die_view_select').click (event) =>
            spec = jQuery(event.target).attr('spec')
            this.addToCurrentDice(window.DiceRoller.diceFactory.create(spec))
        
window.DiceRoller.DiceRoller = DiceRoller