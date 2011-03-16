DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

class DiceRoller
    constructor: (pane_selector) ->
        this.observers = []
        this.element = jQuery(pane_selector)
        this.rollArea = jQuery('.rollArea')
        if window.CachedRESTStorage.isAvailable()
            this.storage = new window.CachedRESTStorage(
                "http://nimbusly-diceroller.appspot.com", "key", window.DiceRoller.diceFactory)
        this.setDiceFromSpec("d6")
        this.setUpRollArea()
        this.refreshView()
        this.setUpDieSelector()
        this.setUpSavedDice()

    addObserver: (viewController) ->
        this.observers.push(viewController)
        
    setDiceFromSpec: (spec) ->
        this.dice = window.DiceRoller.diceFactory.create(spec)
        this.refreshView()
    
    refreshView: ->
        for observer in this.observers
            observer.update(this.dice)
        jQuery('#roll .dice').empty()
        new DiceView(jQuery('#roll .dice'), this.dice)
        jQuery(".rollResult").text(this.currentRoll)
        jQuery("#roll .dieView").click (event) => 
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
    
    newKey: ->
        keys = this.storage.allKeys()
        highKey = keys[keys.length - 1]
        highest = new Number(highKey)
        if isNaN(highest) then "0" else (highest + 1).toString()
        
    saveDiceSet: (dice) ->
        dice.key = this.newKey() unless dice.key
        this.storage.put(dice)
    
    removeDie: (die) ->
        this.dice = this.dice.remove(die)
        this.refreshView()

    setUpRollArea: () ->
        jQuery('#roll .title').click (event) =>
            this.rollDice()
        if this.storage
            jQuery('#roll .save').click (event) =>
                this.saveDiceSet(this.dice)
        else
            jQuery('#roll .save').hide()
            
    DICE_SPECS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF','+1','-1']
        
    setUpSavedDice: ->
        diceSelectionArea = jQuery('#savedDice')
        this.storage.allItems (diceSets) ->
            for diceSet in diceSets
                diceSelectionArea.append(tmpl('diceSetViewTemplate', diceSet))
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