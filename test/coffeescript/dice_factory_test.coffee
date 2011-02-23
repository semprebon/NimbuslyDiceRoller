module "Dice Factory"

diceFactory = window.DiceRoller.diceFactory

test "The dice factory can create a simple die", 2, ->
    dice = diceFactory.create("d6")
    ok(dice instanceof window.DiceRoller.SimpleDie, "should be a simple die")
    equals(dice.typeId, "d6", "d6 should create six-sided simple die")

test "The dice factory can create a fudge die", 2, ->
    dice = diceFactory.create("dF")
    ok(dice instanceof window.DiceRoller.FudgeDie, "should be a fudge die")
    equals(dice.typeId, "dF", "dF should create fudge die")

test "The dice factory can create a n adjustment", 2, ->
    dice = diceFactory.create("+1")
    ok(dice instanceof window.DiceRoller.Adjustment, "should be an adjustment")
    equals(dice.typeId, "+1", "+1 should create adjustment")

test "The dice factory can create a savage die", 2, ->
    dice = diceFactory.create("s12")
    ok(dice instanceof window.DiceRoller.SavageDie, "should be a savage die")
    equals(dice.typeId, "s12", "s12 should create 12-sided savage die")

test "The dice factory can create a sum of dice", 4, ->
    dice = diceFactory.create("s12+2")
    ok(dice instanceof window.DiceRoller.DiceSum, "should be a dice sum")
    equals(dice.dice.length, 2, "should have 2 dice")
    equals(dice.dice[0].typeId, "s12", "first dice should be s12")
    equals(dice.dice[1].typeId, "+2", "second dice should be +2")
    
test "The dice factory can create max of dice", 5, ->
    dice = diceFactory.create("max(d6,d8)")
    ok(dice instanceof window.DiceRoller.DicePickHighest, "should be a pick highest")
    equals(dice.numToPick, 1, "should be pick 1")
    equals(dice.dice.length, 2, "should have 2 dice")
    equals(dice.dice[0].typeId, "d6", "first dice should be d6")
    equals(dice.dice[1].typeId, "d8", "second dice should be d8")
    