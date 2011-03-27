DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

class PageController
    
    getMetrics: () ->
        this.rollDieSize = 120
        footerHeight = jQuery(@pageSelector + ' .ui-footer').height()
        headerHeight = jQuery(@pageSelector + ' .ui-header').height()
        windowHeight = jQuery(window).height()
        this.contentHeight = windowHeight - (footerHeight + headerHeight)

    centerHorizontal: (el) ->
        parent = el.offsetParent()
        el.css("left", (parent.width() - el.width()) / 2)
        
    centerVertical: (el) ->
        parent = el.offsetParent()
        el.css("bottom", (parent.height() - el.height()) / 2)

    centerElement: (el) ->
        this.centerHorizontal(el)
        this.centerVertical(el)

# DiceRoller - The Main Page for the Dice Roller App
    
class DiceRoller extends PageController
    
    constructor: (pageSelector) ->
        @pageSelector = pageSelector
        @observers = []
        @initializeStorage()
        window.DiceRoller.currentDiceSet = window.DiceRoller.diceFactory.createCombo("d6")
        jQuery(@pageSelector).live 'pageshow', (event) => 
            @getMetrics()
            @setUpRollArea()
            @setUpSavedDice()
            @refreshView()
            @setupMainButtons()
        
    addObserver: (viewController) ->
        @observers.push(viewController)
        
    # Methods for working with the roll area
    refreshLayout: ->
        @centerElement(jQuery('#rollPage .rollArea .dice'))
        @centerVertical(jQuery('#rollPage .rollResult'))
        
    setDiceFromSpec: (spec) ->
        dice = window.DiceRoller.diceFactory.createCombo(spec)
        this.setDiceSet(dice)
    
    setDiceSet: (diceSet) ->
        @dice = diceSet
        window.DiceRoller.currentDiceSet = diceSet
        jQuery('#rollPage .ui-title').text(@dice.title)
        @refreshView()

    # Redisplays the roll area with the current dice/results
    refreshView: ->
        @dice = window.DiceRoller.currentDiceSet if window.DiceRoller.currentDiceSet
        console.log("Rolling " + JSON.stringify(@dice))
        for observer in this.observers
            observer.update(@dice)
        jQuery('#rollPage .rollArea .dice').empty()
        new DiceView(jQuery('#rollPage .rollArea .dice'), this.dice)
        @dice.computeResult() if @dice.computeResult
        jQuery("#rollPage .rollResult").text(@dice.currentRoll)
        @refreshLayout()
        jQuery("#rollPage .rollArea .dieView").click (event) => 
            die = event.currentTarget.controller.die
            @rollDice(die)
        
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
        
    # Methods for working with the selection area
    
    selectionAreaHeight: (height) ->
        jQuery('#roll').height(this.activeAreaHeight - height)
        jQuery('#selectionArea').height(height)
        this.refreshLayout()
        
    # Handlers

    createDiceSet: ->
        @setDiceFromSpec("")
        jQuery.mobile.changePage('#buildPage')
    
    rollDice: ->
        @dice.roll()
        @refreshView()
    
    deleteDiceSet: ->
        if (confirm('Delete ' + this.dice.title + "?"))
            this.storage.delete(this.dice.key) if this.dice.key == undefined
        this.setDiceFromSpec("d6")
        this.setUpSavedDice()
        this.setupRollMode()
    
    saveDiceSet: (dice) ->
        @dice.title = @dice.typeId unless @dice.title
        @dice.title = window.prompt("Name of Diceset", @dice.title)
        this.dice.key = this.newKey() unless this.dice.key
        this.storage.put(this.dice)
        this.setUpSavedDice()
        this.setupRollMode()
    
    
    # UI Setup
   
    setUpRollArea: () ->
        jQuery('#rollPage .ui-content').height(this.contentHeight)
        @setDiceSet(window.DiceRoller.currentDiceSet)
        

    setUpSavedDice: ->
        diceSelectionArea = jQuery('#rollPage .savedDice')
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

    setupMainButtons: ->
        jQuery('#rollPage .btn-add').click (event) => @createDiceSet()
        jQuery('#rollPage .#rollArea').click (event) => @rollDice()
        jQuery('#rollPage .btn-save').click (event) => @saveDiceSet()
        
    setupOthers: ->
        jQuery(@pageSelector).bind('pageshow', data, (event) => @refreshView())
            
# DiceBuilder - The editing page for DiceRoller App

class BuildPage extends PageController
    
    DIE_TYPE_IDS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF']    

    constructor: (pageSelector) ->
        @pageSelector = pageSelector
        jQuery(@pageSelector).live 'pageshow', (event) => 
            @getMetrics()
            @setUpRollArea()
            @setUpDieSelector()
            @refreshView()
        
    # Methods for configuring modes
    
    setDiceSet: (diceSet) ->
        @dice = diceSet
        window.DiceRoller.currentDiceSet = diceSet
        jQuery(@pageSelector + ' .ui-title').text(@dice.title)
        @refreshView()

    # Redisplays the roll area with the current dice/results
    refreshView: ->
        diceSetElem = jQuery(@pageSelector + ' .rollArea .dice')
        diceSetElem.empty()
        new DiceView(diceSetElem, this.dice)
        @centerElement(diceSetElem)

        jQuery("#buildPage .rollArea .dieView").click (event) => 
            die = event.currentTarget.controller.die
            @removeDie(die)
        
    removeDie: (die) ->
        console.log('removeDie:' + die.typeId + ' from ' + this.dice.typeId)
        @setDiceSet(@dice.remove(die))
        
    addDice: (die) ->
        unless @dice instanceof window.DiceRoller.DiceCombination
            @dice = new window.DiceRoller.DiceSum([@dice])
        @setDiceSet(@dice.add(die))
        
    setUpRollArea: () ->
        jQuery(@pageSelector + ' .ui-content').height(@contentHeight)
        @setDiceSet(window.DiceRoller.currentDiceSet)

    setUpDieSelector: ->
        diceSelectionArea = jQuery(@pageSelector + ' .dieSelector')
        diceSelectionArea.empty()
        for dieSpec in DIE_TYPE_IDS
            die = window.DiceRoller.diceFactory.create(dieSpec)
            diceSelectionArea.append(tmpl('dieViewTemplate', { id: "dieViewSelect-" + dieSpec, die: die }))
        jQuery(@pageSelector + ' .dieSelector .dieView').click (event) =>
            spec = jQuery(event.currentTarget).attr('spec')
            @addDice(window.DiceRoller.diceFactory.create(spec))

window.DiceRoller.DiceRoller = DiceRoller
window.DiceRoller.BuildPage = BuildPage
