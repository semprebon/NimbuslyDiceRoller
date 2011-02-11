initialize = ->
    $('.input').change (event) =>
        die = window.DiceRoller.SavageDie.fromString(jQuery('#die').val())
        if jQuery('#wildcard')[0].checked
            die = new window.DiceRoller.DicePickHighest(1, die, new window.DiceRoller.SavageDie(6))
        pHit = ([target, die.probToBeat(target).prob] for target in [1..24])
        pRaise = ([target, die.probToBeat(target+4).prob] for target in [1..24])
        jQuery.plot(jQuery('#probabilty_chart'), [pHit, pRaise],
            series: { 
                stack: null, 
                lines: { show: false, steps: false }
                bars: { show: true, barWidth: 0.6 }
            }
        )
    
window.DiceRoller.initialize = initialize