# Tests for DiceOdds calculator

module "Dice Odds"

test "something", 5, ->
    die = new Die(6)
    equal(die.probToRoll(2).prob, 1.0/6.0, "1 out of 6 chance to roll 2")
    equal(die.probToRoll(6).prob, 0.0, "No chance of rolling a 6")
    equal(die.probToRoll(7).prob, 1.0/36.0, "1 of 36 chance of rolling a 7 (6 + 1)")
    equal(die.probToBeat(3).prob, 4.0/6.0, "Beat 2 on 3,4,5,6")
    equal(die.probToBeat(8).prob, 5.0/36.0, "1/6 of getting raise, then roll 2-6")
    
test "adding dice", 5, ->
    dice = new DiceSum(new Die(6), new Die(6))
    deepEqual(dice.waysToRoll(9), [[1,8],[2,7],[3,6],[4,5],[5,4],[6,3],[7,2],[8,1]])
    equal(dice.maxRollOn(dice.dice), Infinity)
    equal(dice.minRollOn(dice.dice), 2)
    equal(dice.probToRoll(2).prob, 1.0/36.0, "must roll 1 on both dice")
    equal(dice.probToRoll(1).prob, 0.0, "can't roll less than 2 on 2 dice")