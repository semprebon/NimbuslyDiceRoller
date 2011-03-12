DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

class DiceSetBuilder
    constructor: (pane_selector) ->
        this.element = jQuery(pane_selector)
        this.possibleDice = jQuery('.possibleDice')
        this.setUpPossibleDice()

    setDiceTo: (spec) ->
        this.dice = window.DiceRoller.diceFactory.create(spec)
        
        
    DICE_SPECS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF','+1','-1']
        
    setUpPossibleDice: ->
        diceSelectionArea = jQuery('.quickPicks')
        for pick in QUICK_PICKS
            diceSelectionArea.append(tmpl('diceSetViewTemplate', { spec: pick[1], name: pick[0] }))
        jQuery(".diceSetPick").click (event) =>
            newSpec = jQuery(event.target).attr('spec')
            this.setDiceTo(newSpec) if newSpec 
            this.rollDice()
        
        
    setUpDiceSelection: ->
        diceSelectionArea = jQuery('#diceSelection')
        for dieSpec in DICE_SPECS
            die = window.DiceRoller.diceFactory.create(dieSpec)
            diceSelectionArea.append(tmpl('dieViewSelectTemplate', die))
        jQuery('.dieViewSelect').click (event) =>
            spec = jQuery(event.target).attr('spec')
            this.addToCurrentDice(window.DiceRoller.diceFactory.create(spec))
        
window.DiceRoller.DiceRoller = DiceRoller