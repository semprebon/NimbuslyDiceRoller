class DiceCalculator
    constructor: (pane_selector) ->
        @element = jQuery(pane_selector)
        @oddsChart = jQuery('#probabilityChart')[0]
        
    update: (dice) ->
        pHit = ([target, dice.probToBeat(target).prob] for target in [1..24])
        pRaise = ([target, dice.probToBeat(target+4).prob] for target in [1..24])
        jQuery.plot(@oddsChart, [pHit, pRaise],
            series: { 
                stack: null, 
                lines: { show: false, steps: false }
                bars: { show: true, barWidth: 0.6 }
            }
        )
    
window.DiceRoller.DiceCalculator = DiceCalculator