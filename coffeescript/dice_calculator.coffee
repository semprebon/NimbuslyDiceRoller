class DiceCalculator
    constructor: (el_selector) ->
        this.element = jQuery(el_selector)
        this.dieSelector =  jQuery(jQuery(el_selector + ' .die')[0])
        this.wildCheckbox = jQuery(jQuery(el_selector + ' .wildcard')[0])
        this.oddsChart = jQuery('#probabilty_chart')[0]
        this.dieSelector.change (event) => this.showOdds()
        this.wildCheckbox.change (event) => this.showOdds()
        
    showOdds: ->
        die = window.DiceRoller.SavageDie.fromString(this.dieSelector.val())
        if this.wildCheckbox[0].checked
            die = new window.DiceRoller.DicePickHighest(1, die, new window.DiceRoller.SavageDie(6))
        pHit = ([target, die.probToBeat(target).prob] for target in [1..24])
        pRaise = ([target, die.probToBeat(target+4).prob] for target in [1..24])
        jQuery.plot(this.oddsChart, [pHit, pRaise],
            series: { 
                stack: null, 
                lines: { show: false, steps: false }
                bars: { show: true, barWidth: 0.6 }
            }
        )
    
window.DiceRoller.DiceCalculator = DiceCalculator