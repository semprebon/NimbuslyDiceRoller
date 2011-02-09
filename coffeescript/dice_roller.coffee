initialize = ->
    $('.input').change (event) =>
        die = window.DiceRoller.SavageDie.fromString(jQuery('#die').val())
        if jQuery('#wildcard')[0].checked
            die = new window.DiceRoller.DicePickHighest(1, die, new window.DiceRoller.SavageDie(6))
        points = ([target, die.probToBeat(target).prob] for target in [1..24])
        jQuery.plot(jQuery('#probabilty_chart'), [
            { data: points, bars: { show: true } }
        ])
    
window.DiceRoller.initialize = initialize