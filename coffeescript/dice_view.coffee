# DieView is the controller for a single die
#
# Attributes:
# * die - the die the view represents
# * id - identifier for the corresponding element
# * updateRoll(newRoll) 

class DieView

    @id_counter = 0

    @next_id: -> 'dieView_' + (@id_counter += 1)
    
    constructor: (parent, die) ->
        @die = die
        @id = DieView.next_id() 
        parent.append(tmpl('dieViewTemplate', this))
        @element().controller = this
    
     element: -> document.getElementById(@id)
     
     updateRoll: (newRoll) -> $(@id + ' .roll').text(String(newRoll))
     
     # disconnect from DOM
     unlinkFromDOM: -> @element().controller = null
         


# DiceView is the controller for a set of dice

class DiceView
    
    constructor: (@parent, @diceSet, @css_class) ->
        @dice = @extractDice(@diceSet)
        @reconstructViews()

    # Extract the dice array from a dice set or die
    
    extractDice: (diceSet) -> if diceSet.dice then diceSet.dice else [diceSet]
    
    # Rebuild the views - called if the dice themselves have changed
    
    reconstructViews: ->
        (view.unlinkFromDOM() for view in @diceViews) if @diceViews
        @parent.empty()
        @diceViews = (new DieView(@parent, die, @css_class) for die in @dice)
        
    # sameDice determines if a new dice set uses the same dice as the current dice set
    
    sameDice: (newDiceSet) ->
        return true if newDiceSet == @diceSet
        newDice = @extractDice(newDiceSet)
        return false if newDice.length != @dice.length
        ok = true
        for i in [0...@dice.length]
            return false unless @dice[i].typeId == newDice[i].typeId
        true
    
    # updateRolls updates the views with the new roll values
    
    updateRolls: (newDiceSet) ->
        for i in [0...@dice.length]
            @diceViews[i].updateRoll(@dice[i].currentRoll)
    
    # Update the view to reflect the new diceSet
    
    updateWith: (diceSet) ->
        if @sameDice(diceSet)
            @updateRolls(diceSet)
        else
            @diceSet = diceSet
            @reconstructViews()
            
window.DiceRoller.DieView = DieView
window.DiceRoller.DiceView = DiceView
