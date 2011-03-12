# Tests for DiceOdds calculator

# sum: d6+d7
# highest 2: [d6,d8,d4][0..1]
# highest: [d6,d4][0]
module "Dice Combos"

nearlyEqual = (actual, expected, message) ->
    if Math.abs(actual - expected) < 0.00001
        equal(actual, actual, message)
    else
        equal(actual, expected, message)
        
DiceRoller = window.DiceRoller

# Test summing combination
diceAdded = new DiceRoller.DiceSum([new DiceRoller.SavageDie(6), new DiceRoller.SimpleDie(4)])
test "s6+d4 should range from 2 to infinity", 2, ->
    equal(diceAdded.max, Infinity)
    equal(diceAdded.min, 2)
test "s6+d4 should compute probababilty to roll exactly", 2, ->
    nearlyEqual(diceAdded.probToRoll(2).prob, 1.0/24.0, "must roll 1 on both dice")
    nearlyEqual(diceAdded.probToRoll(1).prob, 0.0, "can't roll less than 2 on 2 dice")
test "s6+d4 should compute probababilty to roll over", 2, ->
    nearlyEqual(diceAdded.probToRollOver(2).prob, 23.0/24.0, "must not roll 1 on both dice")
    nearlyEqual(diceAdded.probToRollOver(1).prob, 1.0, "can't roll less than 2 on 2 dice")
test "s6+d4 should not roll less than 2", 10, ->
    for i in [1..10]
        ok(diceAdded.roll() >= 2, 'roll greater than 2')

test "s6+d4 should save roll", 1, ->
    roll = diceAdded.roll()
    equal(roll, diceAdded.currentRoll, 'should record roll')

test "adding a die should result in new combination", 2, ->
    dice = diceAdded.add(new DiceRoller.SimpleDie(10))
    equal(dice.dice.length, 3, "should now have 3 dice")
    equal(dice.dice[2].typeId, "d10", "3rd dice should be d10")

test "removing a die should result in new combination", 2, ->
    dice = diceAdded.remove(diceAdded.dice[1])
    equal(dice.dice.length, 1, "should now have 1 die")
    equal(dice.dice[0].typeId, "s6", "first dice should be s6")
    
# Test highest combination
diceHighest = new DiceRoller.DicePickHighest(1, [new DiceRoller.SimpleDie(6), new DiceRoller.SimpleDie(4)])
test "max(d6,d4) should range from 1 to 6", 2, ->
    equal(diceHighest.max, 6)
    equal(diceHighest.min, 1)
test "max(d6,d4) should  have correct probability", 2, ->
    nearlyEqual(diceHighest.probToRoll(2).prob, 3.0/24.0, "must roll 1,2, 2,1, or 2,2")
    nearlyEqual(diceHighest.probToRoll(0).prob, 0.0, "can't roll less than 1")
test "max(d6,d4) should roll between 1 and 6", 10, ->
    for i in [1..10]
        r = diceHighest.roll()
        ok((1 <= r) && (r <= 6), 'roll between 1 and 6')

diceHighest2 = new DiceRoller.DicePickHighest(2, [
        new DiceRoller.SimpleDie(6), 
        new DiceRoller.SimpleDie(4),
        new DiceRoller.SimpleDie(2)
    ])
test "max 2 of (d6,d4,d2) should have correct probability", 1, ->
    nearlyEqual(diceHighest2.probToRoll(2).prob, 4.0/48, "must roll 2s or 1s, (122x3 + 222x1)=4 ways")
