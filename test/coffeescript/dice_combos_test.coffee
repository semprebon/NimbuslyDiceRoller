# Tests for DiceOdds calculator

module "Dice Combos"
    
test "adding dice", 5, ->
    dice = new window.DiceRoller.DiceSum(new window.DiceRoller.SavageDie(6), new window.DiceRoller.SavageDie(6))
    deepEqual(dice.waysToRoll(9), [[1,8],[2,7],[3,6],[4,5],[5,4],[6,3],[7,2],[8,1]])
    equal(dice.max, Infinity)
    equal(dice.min, 2)
    equal(dice.probToRoll(2).prob, 1.0/36.0, "must roll 1 on both dice")
    equal(dice.probToRoll(1).prob, 0.0, "can't roll less than 2 on 2 dice")
    
test "pick highest dice", 4, ->
    dice = new window.DiceRoller.DicePickHighest(1, new window.DiceRoller.SimpleDie(6), new window.DiceRoller.SimpleDie(6))
    equal(dice.max, 6)
    equal(dice.min, 1)
    equal(dice.probToRoll(2).prob, 3.0/36.0, "must roll 1,2, 2,1, or 2,2")
    equal(dice.probToRoll(0).prob, 0.0, "can't roll less than 1")
