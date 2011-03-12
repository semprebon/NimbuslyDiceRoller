class DieView
    constructor: (parent, die) ->
        this.die = die
        this.id = 'dieView_' + Math.floor(Math.random()*100000) 
        parent.append(tmpl('dieViewTemplate', this))
        document.getElementById(this.id).controller = this
        
class DiceView
    constructor: (parent, dice, css_class) -> 
        this.diceViews = []
        dice = if dice.dice then dice.dice else [dice]
        for die in dice
            this.diceViews.push(new DieView(parent, die, css_class))

window.DiceRoller.DieView = DieView
window.DiceRoller.DiceView = DiceView
