
module "Dice Tests"

nearlyEqual = (actual, expected, message) ->
    ok(Math.abs(actual - expected) < 0.00001, message)
    
test "A d6 has correct attributes", 4, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    equals(d6.typeId, "d6", "six sided die should be d6")
    equals(d6.min, 1, "six sided die should have minimum of 1")
    equals(d6.max, 6, "six sided die should have maximum of 6")
    equals(d6.size, 6, "six sided dice should have 6 sides")

test "A d6 has correct probabilities", 6, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    equal(d6.probToRoll(2).prob, 1.0/6.0, "1 out of 6 chance to roll 2")
    equal(d6.probToRoll(7).prob, 0.0, "no chance to roll 7")
    equal(d6.probToRoll(0).prob, 0.0, "no chance to roll 0")
    equal(d6.probToBeat(3).prob, 4.0/6.0, "Beat 3 on 3,4,5,6")
    equal(d6.probToBeat(-1).prob, 1.0, "Always beat -1")
    equal(d6.probToBeat(7).prob, 0.0, "Never beat 7")
    
test "A d6 has correct range", 4, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    ok(!d6.inRange(0), "0 is not in range")
    ok(d6.inRange(1), "1 is in range")
    ok(d6.inRange(6), "6 is in range")
    ok(!d6.inRange(7), "7 is not in range")
    
test "A d6 rolls correctly", 10, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    for i in [1..10]
        roll = d6.roll()
        ok(1 <= roll && roll <= 6, roll + "is between 1 and 6")

    
test "A d8 has correct attributes", 1, ->    
    d8 = new window.DiceRoller.SimpleDie(8)
    equals(d8.typeId, "d8", "eight sided die should be d8")

test "A d8 rolls correctly", 10, ->
    d8 = new window.DiceRoller.SimpleDie(8)
    for i in [1..10]
        roll = d8.roll()
        ok(1 <= roll && roll <= 8, roll + " between 1 and 8")

test "SimpleDie should create simple dice from valid strings", 2, ->
    equal(window.DiceRoller.SimpleDie.fromString("d4").size, 4, "d4 should have 4 sides")
    equal(window.DiceRoller.SimpleDie.fromString("d10").size, 10, "d10 should have 10 sides")

test "A SimpleDie fatory should not create dice from non-simple type ids", 6, ->
        equals(window.DiceRoller.SimpleDie.fromString("s4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("-4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("dF"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("xf5"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("s4"), undefined)


test "A Fudge die has a distribution between -1 and +1", 10, ->
    df = new window.DiceRoller.FudgeDie()
    for i in [1..10]
        roll = df.roll()
        ok(-1 <= roll && roll <= 1, roll + " between -1 and 1")
    
test 'A Fudge die should have correct attributes', 1, ->
    df = new window.DiceRoller.FudgeDie()
    equals(df.typeId, "dF");

test "A Fudge die has correct probabilities", 7, ->
        die = new window.DiceRoller.FudgeDie()
        equal(die.probToRoll(-1).prob, 1.0/3.0, "1 out of 3 chance to roll -1")
        equal(die.probToRoll(0).prob, 1.0/3.0, "1 out of 3 chance to roll 0")
        equal(die.probToRoll(+1).prob, 1.0/3.0, "1 out of 3 chance to roll +1")
        equal(die.probToRoll(2).prob, 0.0, "no chance to roll 2")
        equal(die.probToBeat(0).prob, 2.0/3.0, "Beat 0 on 0, +1")
        equal(die.probToBeat(-1).prob, 1.0, "Always beat -1")
        equal(die.probToBeat(2).prob, 0.0, "Never beat 2")
        
test 'The FudgeDie factory should create a fudge dice from a type id', ->
    equals(window.DiceRoller.FudgeDie.fromString("dF").size, 3, "dF should have size 3")

test 'The FudgeDie factory should not create fudge dice from non-fudge type ids', 5, ->
     equals(window.DiceRoller.FudgeDie.fromString("s4"), undefined)
     equals(window.DiceRoller.FudgeDie.fromString("4"), undefined)
     equals(window.DiceRoller.FudgeDie.fromString("-4"), undefined)
     equals(window.DiceRoller.FudgeDie.fromString("d4"), undefined)
     equals(window.DiceRoller.FudgeDie.fromString("1dF"), undefined)
     
test 'A +6 adjustment should have a distribution between 6 and 6', 10, ->
    adjustment = new window.DiceRoller.Adjustment(6)
    for i in [1..10]
        roll = adjustment.roll()
        ok(roll == 6, roll + " = 6")
 
test 'A +6 adjustment should have correct attributes', 1, ->
     die = new window.DiceRoller.Adjustment(-4)
     equals(die.typeId, "-4");

 test "An adjustment has correct probabilities", 5, ->
     die = new window.DiceRoller.Adjustment(4)
     equal(die.probToRoll(4).prob, 1.0, "always rolls 4")
     equal(die.probToRoll(5).prob, 0.0, "nnever rolls 5")
     equal(die.probToRoll(3).prob, 0.0, "nnever rolls 3")
     equal(die.probToRoll(4).prob, 1.0, "always beats 4")
     equal(die.probToRoll(3).prob, 0.0, "never beats 3")

test 'The Adjustment factory should create an adjustment from a type id', 3, ->
     equals(window.DiceRoller.Adjustment.fromString("+2").typeId, "+2")
     equals(window.DiceRoller.Adjustment.fromString("4").typeId, "+4")
     equals(window.DiceRoller.Adjustment.fromString("-3").typeId, "-3")

test 'The Adjustment factory should not create adjustments from non-adjustment type ids', 3, ->
     equals(window.DiceRoller.Adjustment.fromString("s4"), undefined)
     equals(window.DiceRoller.Adjustment.fromString("dF"), undefined)
     equals(window.DiceRoller.Adjustment.fromString("d4"), undefined)

test "A savage d6 has a distribution between 1 and n", 10, ->
    die = new window.DiceRoller.Adjustment(6)
    for i in [1..10]
        roll = die.roll()
        ok(roll >= 1, roll + " >= 1")
     
test "A savage d6 has correct attributes", 2, ->
     die = new window.DiceRoller.SavageDie(6);
     equals(die.typeId, "s6")
     equals(die.size, 6)
     
test "A savage die has correct probabilities", 6, ->
     die = new window.DiceRoller.SavageDie(10)
     equal(die.probToRoll(9).prob, 1.0/10.0, "1 out of 10 chance to roll 9")
     equal(die.probToRoll(10).prob, 0.0, "never roll 10")
     nearlyEqual(die.probToRoll(11).prob, 1.0/100.0, "1 out of 100 chance to roll 11")
     equal(die.probToBeat(9).prob, 2.0/10.0, "2 out of 10 chance to beat 9")
     nearlyEqual(die.probToBeat(20).prob, 1.0/100.0, "chance to Beat 20")
     equal(die.probToBeat(1).prob, 1.0, "Always beat 1")
     
test "A SavageDie fatory should create savage dice from type ids", 2, ->
     equals(window.DiceRoller.SavageDie.fromString("s4").typeId, "s4")
     equals(window.DiceRoller.SavageDie.fromString("s6").size, 6)

test "A SavageDie fatory should not create dice from non-savage type ids", 5, ->
     equals(window.DiceRoller.SavageDie.fromString("d4"), undefined)
     equals(window.DiceRoller.SavageDie.fromString("4"), undefined)
     equals(window.DiceRoller.SavageDie.fromString("-4"), undefined)
     equals(window.DiceRoller.SavageDie.fromString("dF"), undefined)
     equals(window.DiceRoller.SavageDie.fromString("xf5"), undefined)

