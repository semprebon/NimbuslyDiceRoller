module "Probabilty"

nearlyEqual = (actual, expected, message) ->
    ok(Math.abs(actual - expected) < 0.00001, message)
    
p1 = new DiceRoller.Probability(0.3)
p2 = new DiceRoller.Probability(0.2)
test "and multiplies probabilities", 1, ->
    equals(p1.and(p2).prob, 0.06, "2/10 && 3/10 = 6/100")
