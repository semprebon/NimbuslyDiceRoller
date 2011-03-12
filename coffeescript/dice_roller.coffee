DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

class DiceRoller
    constructor: (pane_selector) ->
        this.observers = []
        this.element = jQuery(pane_selector)
        this.rollArea = jQuery('.rollArea')
        this.setDiceFromSpec("d6")
        this.setUpRollArea()
        this.refreshView()
        this.setUpDieSelector()
        this.setUpSavedDice()

    addObserver: (viewController) ->
        this.observers.push(viewController)
        
    setDiceFromSpec: (spec) ->
        this.dice = window.DiceRoller.diceFactory.create(spec)
    
    refreshView: ->
        for observer in this.observers
            observer.update()
        this.rollArea.empty()
        new DiceView(this.rollArea, this.dice)
        jQuery(".rollResult").text(this.currentRoll)
        jQuery("#roll .dice").click (event) => 
            die = event.currentTarget.controller.die
            this.removeDie(die)
        
    rollDice: ->
        this.dice.roll()
        this.refreshView()
    
    addDice: (die) ->
        unless this.dice instanceof window.DiceRoller.DiceCombination
            this.dice = new window.DiceRoller.DiceSum([this.dice])
        this.dice = this.dice.add(die)
        this.refreshView()
    
    removeDie: (die) ->
        this.dice = this.dice.remove(die)
        this.refreshView()

    setUpRollArea: () ->
        jQuery('#roll .title').click (event) =>
            this.rollDice()
            
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
        
    setUpSavedDice: ->
        diceSelectionArea = jQuery('#savedDice')
        for pick in QUICK_PICKS
            diceSelectionArea.append(tmpl('diceSetViewTemplate', { spec: pick[1], name: pick[0] }))
        jQuery(".diceSetPick").click (event) =>
            newSpec = jQuery(event.currentTarget).attr('spec')
            this.setDiceFromSpec(newSpec) if newSpec 

    setUpDieSelector: ->
        diceSelectionArea = jQuery('#dieSelector')
        for dieSpec in DICE_SPECS
            die = window.DiceRoller.diceFactory.create(dieSpec)
            diceSelectionArea.append(tmpl('dieViewTemplate', { id: "dieViewSelect-" + dieSpec, die: die }))
        jQuery('#dieSelector .dieView').click (event) =>
            spec = jQuery(event.currentTarget).attr('spec')
            this.addDice(window.DiceRoller.diceFactory.create(spec))
        
window.DiceRoller.DiceRoller = DiceRoller