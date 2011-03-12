class DiceCalculator
    constructor: (pane_selector) ->
        this.element = jQuery(pane_selector)
        this.oddsChart = jQuery('#probabiltyChart')[0]
        jQuery(".dice_set_pick").click (event) =>
            newSpec = jQuery(event.target).attr('spec')
            this.showOdds(newSpec)
        
    showOdds: (spec) ->
        dice = window.DiceRoller.diceFactory.create(spec)
        pHit = ([target, dice.probToBeat(target).prob] for target in [1..24])
        pRaise = ([target, dice.probToBeat(target+4).prob] for target in [1..24])
        jQuery.plot(this.oddsChart, [pHit, pRaise],
            series: { 
                stack: null, 
                lines: { show: false, steps: false }
                bars: { show: true, barWidth: 0.6 }
            }
        )
    
window.DiceRoller.DiceCalculator = DiceCalculator