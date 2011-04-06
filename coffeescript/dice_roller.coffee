DieView = window.DiceRoller.DieView
DiceView = window.DiceRoller.DiceView

LAST_USED_STORAGE_KEY = 'lastUsedDiceSetTypeId'

# PageController is the base class for the main page UI controllers. It consists of a number of
# utility functions for laying out the screen and accessing app-wide resources.
#
# Derived classes should override refreshDiceSet, which refreshes the view when the current dice set
# is changed.

class PageController
    
    getMetrics: () ->
        @rollDieSize = 120
        footerHeight = jQuery(@pageSelector + ' .ui-footer').height()
        headerHeight = jQuery(@pageSelector + ' .ui-header').height()
        windowHeight = jQuery(window).height()
        @contentHeight = windowHeight - (footerHeight + headerHeight)

    # Center an element horizonatally in its parent. The parent must be positioned, and the element
    # should be absolutely positioned.

    centerHorizontal: (el) ->
        parent = el.offsetParent()
        el.css("left", (parent.width() - el.width()) / 2)
        
    # Center an element vertically in its parent. The parent must be positioned, and the element 
    # should be absolutely positioned.

    centerVertical: (el) ->
        parent = el.offsetParent()
        el.css("bottom", (parent.height() - el.height()) / 2)

    # Center an element in its parent. The parent must be positioned, and the element 
    # should be absolutely positioned.

    centerElement: (el) ->
        @centerHorizontal(el)
        @centerVertical(el)

    # Set the title of the page. Normally, the title is the name of the saved dice, if the current
    # dice is saved.
    
    setTitle: (newTitle) ->
        jQuery(@pageSelector + ' .ui-title').text(newTitle)
    
    # Sets the current dice set to the specified dice set, and updates anything that needs to
    # be updated.
    
    setDiceSet: (diceSet) ->
        @dice = diceSet
        window.DiceRoller.currentDiceSet = diceSet
        localStorage[LAST_USED_STORAGE_KEY] = if @dice.key then @dice.key else @dice.typeId
        @setTitle(if diceSet.title then diceSet.title else 'Nimbusly Dice Roller')
        @refreshDiceSet()

        
# DiceRoller is the controller for the rolling page
    
class DiceRoller extends PageController
    
    constructor: (pageSelector) ->
        @pageSelector = pageSelector
        @observers = []
        @initializeStorage()
        keyOrTypeId = localStorage[LAST_USED_STORAGE_KEY]
        keyOrTypeId = "d6" unless keyOrTypeId
        diceSet = @storage.getLocal(keyOrTypeId)
        diceSet = window.DiceRoller.diceFactory.createCombo(keyOrTypeId) unless diceSet
        window.DiceRoller.currentDiceSet = diceSet
        jQuery(@pageSelector).live 'pageshow', (event) => 
            @getMetrics()
            @setUpRollArea()
            @setUpSavedDice()
            @refreshDiceSet()
            @setupMainButtons()
        
    addObserver: (viewController) ->
        #@observers.push(viewController)
        
    # Methods for working with the roll area
    refreshLayout: ->
        rollAreaHeight = jQuery(@pageSelector + ' .rollArea')
        diceView = $(@pageSelector + ' .rollArea .dice')
        @centerHorizontal(diceView)
        diceView.css("top", (rollAreaHeight/4 - diceView.height()/2))
        
        resultView = $(@pageSelector + ' .rollArea .result')
        @centerHorizontal(resultView)
        diceView.css("top", (rollAreaHeight*3/4 - resultView.height()/2))
        
    setDiceFromSpec: (spec) ->
        dice = window.DiceRoller.diceFactory.createCombo(spec)
        @setDiceSet(dice)
    
    # refreshDiceSet redisplays the current dice set after any changes have been made.

    refreshDiceSet: ->
        for observer in @observers
            observer.update(@dice)
        if @dice.key
            $(@pageSelector + ' .btn-delete').show()
        else
            $(@pageSelector + ' .btn-delete').hide()
        
        if @diceView && @diceView.diceSet.typeId == @dice.typeId
            @diceView.updateWith(@dice)
        else
            @diceView = new DiceView(jQuery('#rollPage .rollArea .dice'), @dice)
        @dice.computeResult() if @dice.computeResult
        jQuery(@pageSelector + " .rollResult").text(@dice.currentRoll)
        @refreshLayout()
        jQuery(@pageSelector + " .rollArea .dieView").click (event) => 
            die = event.currentTarget.controller.die
            @rollDice(die)
    
    # Redisplays the roll area with the current dice/results

    refreshView: ->
        @dice = window.DiceRoller.currentDiceSet if window.DiceRoller.currentDiceSet
        @refreshDiceSet()
        
    # Methods for working with storage
    
    initializeStorage: ->
        if window.CachedRESTStorage.isAvailable()
            @storage = new window.CachedRESTStorage(
                "http://nimbusly-diceroller.appspot.com", "key", window.DiceRoller.diceFactory)
        else
            console.log("No local storage")
        
    newKey: ->
        keys = @storage.allKeys()
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
        @dice.title = newTitle
        jQuery('#title .show span').text(newTitle)
        jQuery('#title div.edit').hide()
        jQuery('#title div.show').show()
        
    # Methods for working with the selection area
    
    selectionAreaHeight: (height) ->
        jQuery('#roll').height(@activeAreaHeight - height)
        jQuery('#selectionArea').height(height)
        @refreshLayout()
        
    # Handlers

    createDiceSet: ->
        @setDiceFromSpec("")
        jQuery.mobile.changePage('#buildPage')
    
    rollDice: ->
        @dice.roll()
        @refreshDiceSet()
    
    deleteDiceSet: ->
        if (confirm('Delete ' + @dice.title + "?"))
            @storage.delete(@dice.key) if @dice.key != undefined
        @setDiceFromSpec("d6")
        @setUpSavedDice()
    
    saveDiceSet: (dice) ->
        @dice.title = @dice.typeId unless @dice.title
        @dice.title = window.prompt("Name of Diceset", @dice.title)
        @setTitle(@dice.title)
        @dice.key = @newKey() unless @dice.key
        @storage.put(@dice)
        @setUpSavedDice()
    
    
    # UI Setup
   
    setUpRollArea: () ->
        jQuery('#rollPage .ui-content').height(@contentHeight)
        @setDiceSet(window.DiceRoller.currentDiceSet)
        $(@pageSelector + ' .btn-delete').click => @deleteDiceSet()
        
    setupNewDiceSavedDiceSet: ->
        diceSet = window.DiceRoller.diceFactory.createCombo('d6')
        diceSet.title = '*New*'
        diceSet.key = ""
        jQuery('#rollPage .savedDice').append(tmpl('diceSetViewTemplate', diceSet))

    setUpSavedDice: ->
        diceSelectionArea = jQuery('#rollPage .savedDice')
        diceSelectionArea.empty()
        @setupNewDiceSavedDiceSet()
        @storage.allItems (diceSets) ->
            for diceSet in diceSets
                diceSet.title = diceSet.typeId unless diceSet.title
                diceSelectionArea.append(tmpl('diceSetViewTemplate', diceSet))
                elem = document.getElementById('select-' + diceSet.key)
                elem.diceSet = diceSet if elem
        jQuery(".diceSetPick").click (event) =>
            diceSet = event.currentTarget.diceSet
            @setDiceSet(diceSet) if diceSet 

    setupMainButtons: ->
        jQuery('#rollPage .btn-add').click (event) => @createDiceSet()
        jQuery('#rollPage .#rollArea').click (event) => @rollDice()
        jQuery('#rollPage .btn-save').click (event) => @saveDiceSet()
        
    setupOthers: ->
        jQuery(@pageSelector).bind('pageshow', data, (event) => @refreshDiceSet())
            
# DiceBuilder - The editing page for DiceRoller App

class BuildPage extends PageController
    
    DIE_TYPE_IDS = ['d4','d6','d8','d10','d12','s4','s6','s8','s10','s12','dF']    

    constructor: (pageSelector) ->
        @pageSelector = pageSelector
        jQuery(@pageSelector).live 'pageshow', (event) => 
            @getMetrics()
            @setUpRollArea()
            @setUpDieSelector()
            @refreshDiceSet()
        
    # Methods for configuring modes
    
    setDiceSet: (diceSet) ->
        @dice = diceSet
        window.DiceRoller.currentDiceSet = diceSet
        jQuery(@pageSelector + ' .ui-title').text(@dice.title)
        @refreshDiceSet()

    # Redisplays the roll area with the current dice/results
    refreshDiceSet: ->
        diceSetElem = jQuery(@pageSelector + ' .rollArea .dice')
        diceSetElem.empty()
        new DiceView(diceSetElem, @dice)
        @centerElement(diceSetElem)

        jQuery("#buildPage .rollArea .dieView").click (event) => 
            die = event.currentTarget.controller.die
            @removeDie(die)
        
    removeDie: (die) ->
        console.log('removeDie:' + die.typeId + ' from ' + @dice.typeId)
        @setDiceSet(@dice.remove(die))
        
    addDice: (die) ->
        [title, key] = [@dice.title, @dice.key]
        unless @dice instanceof window.DiceRoller.DiceCombination
            @dice = new window.DiceRoller.DiceSum([@dice])
        @dice = @dice.add(die)
        @dice.title = title
        @dice.key = key
        @setDiceSet(@dice)
    
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
