DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

class DiceRoller
    
    DIE_TYPE_IDS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF']    

    constructor: (pane_selector) ->
        this.observers = []
        this.element = jQuery(pane_selector)
        this.initializeStorage()
        this.getMetrics()
        this.setUpRollArea()
        this.refreshView()
        this.setUpDieSelector()
        this.setUpSavedDice()
        this.setupMainButtons()
        this.activateSavedDice()
        
    centerHorizontal: (el) ->
        parent = el.offsetParent()
        el.css("left", (parent.width() - el.width()) / 2)
        
    centerVertical: (el) ->
        parent = el.offsetParent()
        el.css("bottom", (parent.height() - el.height()) / 2)

    centerElement: (el) ->
        this.centerHorizontal(el)
        this.centerVertical(el)

    addObserver: (viewController) ->
        this.observers.push(viewController)
        
    # Methods for working with the roll area
    refreshLayout: ->
        this.centerElement(jQuery('#roll .dice'))
        this.centerVertical(jQuery('#roll .rollResult'))
        
    setDiceFromSpec: (spec) ->
        this.setDiceSet(window.DiceRoller.diceFactory.create(spec))
    
    setDiceSet: (diceSet) ->
        this.dice = diceSet
        jQuery('#roll .title .show span').text(this.dice.title)
        this.refreshView()

    refreshView: ->
        for observer in this.observers
            observer.update(this.dice)
        jQuery('#roll .dice').empty()
        new DiceView(jQuery('#roll .dice'), this.dice)
        this.dice.computeResult() if this.dice.computeResult
        jQuery("#roll .rollResult").text(this.dice.currentRoll)
        this.refreshLayout()
        jQuery("#roll .dieView").click (event) => 
            die = event.currentTarget.controller.die
            this.removeDie(die)
        
    # Methods for working with the main action buttons at the bottom of the screen
    
    mainButton: (name) -> jQuery('#mainButtons .' + name)
    
    mainButtonRefresh: ->
        count = jQuery("#mainButtons button:visible").length
        outerButtonWidth = jQuery('#mainButtons').width() / count
        padding = jQuery('#mainButtons .roll').outerWidth() - jQuery('#mainButtons .roll').width()
        jQuery("#mainButtons button:visible").width(outerButtonWidth - padding)
    
    showMainButton: (name) -> this.mainButton(name).show(); this.mainButtonRefresh()
        
    hideMainButton: (name) -> this.mainButton(name).hide(); this.mainButtonRefresh()
    
    switchMainButtons: (toShow, toHide) -> 
        this.mainButton(toShow).show()
        this.mainButton(toHide).hide()
        this.mainButtonRefresh()
    
    onMainButtonClick: (name, handler) -> this.mainButton(name).click(handler)
    
    # Methods for working with storage
    
    initializeStorage: ->
        if window.CachedRESTStorage.isAvailable()
            this.storage = new window.CachedRESTStorage(
                "http://nimbusly-diceroller.appspot.com", "key", window.DiceRoller.diceFactory)
        else
            console.log("No local storage")
        
    newKey: ->
        keys = this.storage.allKeys()
        highKey = keys[keys.length - 1]
        highest = new Number(highKey)
        if isNaN(highest) then "0" else (highest + 1).toString()
    
    
    # Methods for manipulating the title
    
    editTitle: ->
        jQuery('#title .edit input').val(jQuery('#title .show span').text())
        jQuery('#title .show').hide()
        jQuery('#title .edit').show()
        
    saveTitle: ->
        newTitle = jQuery('#title .edit input').val()
        this.dice.title = newTitle
        jQuery('#title .show span').text(newTitle)
        jQuery('#title div.edit').hide()
        jQuery('#title div.show').show()
        
    # Methods for configuring modes
    
    setupRollMode: ->
        this.activateSavedDice()
        this.showMainButton('roll')
        this.switchMainButtons('edit', 'save')
        this.hideMainButton('delete')
        this.showMainButton('create')
        
    # Methods for working with the selection area
    
    activateSavedDice: ->
        jQuery('#savedDice').addClass('active')
        jQuery('#dieSelector').removeClass('active')
        this.selectionAreaHeight(this.rollDieSize)
        
    activateDieSelector: ->
        jQuery('#savedDice').removeClass('active')
        jQuery('#dieSelector').addClass('active')
        height = this.activeAreaHeight - this.rollDieSize
        this.selectionAreaHeight(height)

    selectionAreaHeight: (height) ->
        jQuery('#roll').height(this.activeAreaHeight - height)
        jQuery('#selectionArea').height(height)
        this.refreshLayout()
        
    # Handlers

    editDiceSet: ->
        this.editTitle()
        if this.dice.isEmpty() then this.hideMainButton('save') else this.showMainButton('save')  
        this.hideMainButton('edit')
        this.showMainButton('delete') if this.dice.key
        this.hideMainButton('create')
        this.activateDieSelector()
    	
    saveDiceSet: (dice) ->
        this.saveTitle()
        this.dice.key = this.newKey() unless this.dice.key
        this.storage.put(this.dice)
        this.setUpSavedDice()
        this.setupRollMode()
    
    deleteDiceSet: ->
        if (confirm('Delete ' + this.dice.title + "?"))
            this.storage.delete(this.dice.key) if this.dice.key
        this.setDiceFromSpec("d6")
        this.setUpSavedDice()
        this.setupRollMode()
    
    createDiceSet: ->
        this.setDiceFromSpec("")
        this.editDiceSet()
        
    
    rollDice: ->
        this.dice.roll()
        this.refreshView()
    
    removeDie: (die) ->
        console.log('removeDie:' + die.typeId + ' from ' + this.dice.typeId)
        this.dice = this.dice.remove(die)
        this.hideMainButton('save') if this.dice.isEmpty()
        this.refreshView()
        
    addDice: (die) ->
        unless this.dice instanceof window.DiceRoller.DiceCombination
            this.dice = new window.DiceRoller.DiceSum([this.dice])
        this.dice = this.dice.add(die)
        this.showMainButton('save') unless this.dice.isEmpty()
        this.refreshView()
    
    # UI Setup
    
    getMetrics: () ->
        this.rollDieSize = 120
        this.mainButtonHeight = jQuery('#mainButtons').height()
        this.titleHeight = jQuery('#title').height()
        this.screenHeight = jQuery('body').height()
        this.activeAreaHeight = this.screenHeight - (this.mainButtonHeight + this.titleHeight)

    setUpRollArea: () ->
        this.setDiceFromSpec("d6")

    setUpSavedDice: ->
        diceSelectionArea = jQuery('#savedDice')
        diceSelectionArea.empty()
        this.storage.allItems (diceSets) ->
            for diceSet in diceSets
                diceSet.title = diceSet.typeId unless diceSet.title
                diceSelectionArea.append(tmpl('diceSetViewTemplate', diceSet))
                elem = document.getElementById('select-' + diceSet.key)
                elem.diceSet = diceSet if elem
        jQuery(".diceSetPick").click (event) =>
            diceSet = event.currentTarget.diceSet
            this.setDiceSet(diceSet) if diceSet 

    setUpDieSelector: ->
        diceSelectionArea = jQuery('#dieSelector')
        diceSelectionArea.empty()
        for dieSpec in DIE_TYPE_IDS
            die = window.DiceRoller.diceFactory.create(dieSpec)
            diceSelectionArea.append(tmpl('dieViewTemplate', { id: "dieViewSelect-" + dieSpec, die: die }))
        jQuery('#dieSelector .dieView').click (event) =>
            spec = jQuery(event.currentTarget).attr('spec')
            this.addDice(window.DiceRoller.diceFactory.create(spec))
 
    setupMainButtons: ->
        this.onMainButtonClick('roll', => this.rollDice())
        this.onMainButtonClick('edit', => this.editDiceSet())
        this.onMainButtonClick('save', => this.saveDiceSet())
        this.onMainButtonClick('delete', => this.deleteDiceSet())
        this.onMainButtonClick('create', => this.createDiceSet())
        this.setupRollMode()
        this.switchMainButtons('edit','save')
        this.hideMainButton('delete')

window.DiceRoller.DiceRoller = DiceRoller