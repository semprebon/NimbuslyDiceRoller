# Tests for DiceOdds calculator

# sum: d6+d7
# highest 2: [d6,d8,d4][0..1]
# highest: [d6,d4][0]
module "Dice Combos"

nearlyEqual = (actual, expected, message) ->
    ok(Math.abs(actual - expected) < 0.00001, message)
    
test "adding dice", 7, ->
    dice = new window.DiceRoller.DiceSum(new window.DiceRoller.SavageDie(6), new window.DiceRoller.SavageDie(6))
    deepEqual(dice.waysToRoll(9), [[1,8],[2,7],[3,6],[4,5],[5,4],[6,3],[7,2],[8,1]])
    equal(dice.max, Infinity)
    equal(dice.min, 2)
    nearlyEqual(dice.probToRoll(2).prob, 1.0/36.0, "must roll 1 on both dice")
    nearlyEqual(dice.probToRoll(1).prob, 0.0, "can't roll less than 2 on 2 dice")
    ok(dice.roll() > 0, 'roll greater than 0')
    equal(dice.rollDice().rolls.length, 2, 'should roll 2 dice')
    
test "pick highest dice", 6, ->
    dice = new window.DiceRoller.DicePickHighest(1, new window.DiceRoller.SimpleDie(6), new window.DiceRoller.SimpleDie(6))
    equal(dice.max, 6)
    equal(dice.min, 1)
    nearlyEqual(dice.probToRoll(2).prob, 3.0/36.0, "must roll 1,2, 2,1, or 2,2")
    nearlyEqual(dice.probToRoll(0).prob, 0.0, "can't roll less than 1")
    ok(dice.roll() > 0, 'roll greater than 0')
    equal(dice.rollDice().rolls.length, 2, 'should roll 2 dice')
