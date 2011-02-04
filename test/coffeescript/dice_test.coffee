
module("Dice Tests");

module "SimpleDie"

test "A d6 has correct attributes", 4, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    equals(d6.typeId, "d6", "six sided die should be d6")
    equals(d6.min, 1, "six sided die should have minimum of 1")
    equals(d6.max, 6, "six sided die should have maximum of 6")
    equals(d6.sides, 6, "six sided dice should have 6 sides")

test "A d6 has correct probabilities", 6, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    equal(d6.probToRoll(2).prob, 1.0/6.0, "1 out of 6 chance to roll 2")
    equal(d6.probToRoll(7).prob, 0.0, "no chance to roll 7")
    equal(d6.probToRoll(0).prob, 0.0, "no chance to roll 0")
    equal(d6.probToBeat(3).prob, 4.0/6.0, "Beat 3 on 3,4,5,6")
    equal(d6.probToBeat(-1).prob, 1.0, "Always beat -1")
    equal(d6.probToBeat(7).prob, 0.0, "Never beat 7")
    
test "A d6 has correct range", 6, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    ok(!d6.inRange(0), "0 is not in range")
    ok(d6.inRange(1), "1 is in range")
    ok(d6.inRange(6), "6 is in range")
    ok(!d6.inRange(7), "7 is not in range")
    
test "A d6 rolls correctly", 10, ->
    d6 = new window.DiceRoller.SimpleDie(6)
    for i in [1..10]
        roll = d6.roll
        ok(1 <= roll && roll <= 6, "roll between 1 and 6")

    
test "A d8 has correct attributes", 1, ->    
    d8 = new window.DiceRoller.SimpleDie(8)
    equals(d8.typeId, "d8", "eight sided die should be d8")

test "A d8 rolls correctly", 10, ->
    d8 = new window.DiceRoller.SimpleDie(8)
    for i in [1..10]
        roll = d8.roll
        ok(1 <= roll && roll <= 6, "roll between 1 and 6")

test "SimpleDie should create simple dice from valid strings", 1, ->
    equal(window.DiceRoller.SimpleDie.fromString("d4").sides, 4, "d4 should have 4 sides")
    equal(window.DiceRoller.SimpleDie.fromString("d10").sides, 10, "d10 should have 10 sides")

test "A SimpleDie fatory should not create dice from non-simple type ids", 6, ->
        equals(window.DiceRoller.SimpleDie.fromString("s4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("-4"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("dF"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("xf5"), undefined)
        equals(window.DiceRoller.SimpleDie.fromString("s4"), undefined)

#     test("A Fudge die has a distribution between -1 and +1", 2, function() {
#         var die = new window.DiceRoller.FudgeDie();
#         var distribution = new Distribution(die)
#         equals(distribution.min, -1);
#         equals(distribution.max, +1);
#     });
#     
#     test('A Fudge die should have correct attributes', 1, function() {
#         var die = new window.DiceRoller.FudgeDie();
#         equals(die.typeId(), "dF");
#         
#     });
# 
#     test('A Fudge die should display its value as "-1", "0", or "+1"', 3, function() {
#         equals((new window.DiceRoller.FudgeDie(-1)).display(), "-1");
#         equals((new window.DiceRoller.FudgeDie(0)).display(), "0");
#         equals((new window.DiceRoller.FudgeDie(1)).display(), "+1");
#     });
# 
#     test('The FudgeDie factory should create a fudge dice from a type id', function() {
#         dieEquals(window.DiceRoller.FudgeDie.fromId("dF"), new window.DiceRoller.FudgeDie());
#     });
#     
#     test('The FudgeDie factory should not create fudge dice from non-fudge type ids', 5, function() {
#         equals(window.DiceRoller.FudgeDie.fromId("s4"), undefined);
#         equals(window.DiceRoller.FudgeDie.fromId("4"), undefined);
#         equals(window.DiceRoller.FudgeDie.fromId("-4"), undefined);
#         equals(window.DiceRoller.FudgeDie.fromId("d4"), undefined);
#         equals(window.DiceRoller.FudgeDie.fromId("1dF"), undefined);
#     });
#     
#     test('A +6 adjustment should have a distribution between 6 and 6', 2, function() {
#         var die = new window.DiceRoller.Adjustment(6);
#         var distribution = new Distribution(die)
#         equals(distribution.min, 6);
#         equals(distribution.max, 6);
#     });
# 
#     test('A +6 adjustment should have correct attributes', 1, function() {
#         var die = new window.DiceRoller.Adjustment(-4);
#         equals(die.typeId(), "-4");
#         
#     });
# 
#     test('An adjustment should display as + or - the number', 2, function() {
#         equals((new window.DiceRoller.Adjustment(6)).display(), "+6");
#         equals((new window.DiceRoller.Adjustment(-2)).display(), "-2");
#     });
# 
#     test('The Adjustment factory should create an adjustment from a type id', function() {
#         dieEquals(window.DiceRoller.Adjustment.fromId("+2"), new window.DiceRoller.Adjustment(2));
#         dieEquals(window.DiceRoller.Adjustment.fromId("4"), new window.DiceRoller.Adjustment(4));
#         dieEquals(window.DiceRoller.Adjustment.fromId("-3"), new window.DiceRoller.Adjustment(-3));
#     });
#     
#     test('The Adjustment factory should not create adjustments from non-adjustment type ids', 3, function() {
#         equals(window.DiceRoller.Adjustment.fromId("s4"), undefined);
#         equals(window.DiceRoller.Adjustment.fromId("dF"), undefined);
#         equals(window.DiceRoller.Adjustment.fromId("d4"), undefined);
#     });
# 
# 
#     test("A savage d6 has a distribution between 1 and n", 3, function() {
#         var die = new window.DiceRoller.SavageDie(6);
#         var distribution = new Distribution(die)
#         equals(distribution.min, 1);
#         equals(distribution.hitsFor[6], undefined);
#         equals(distribution.hitsFor[12], undefined);
#     });
#     
#     test("A savage d6 has correct attributes", 2, function() {
#         var die = new window.DiceRoller.SavageDie(6);
#         equals(die.typeId(), "s6");
#         equals(die.display(), "1");
#     });
#     
#     test("A SavageDie fatory should create simple dice from type ids", 2, function() {
#         dieEquals(window.DiceRoller.SavageDie.fromId("s4"), new window.DiceRoller.SavageDie(4));
#         dieEquals(window.DiceRoller.SavageDie.fromId("s6"), new window.DiceRoller.SavageDie(6));
#     });
# 
#     test("A SimpleDie fatory should not create dice from non-simple type ids", 5, function() {
#         equals(window.DiceRoller.SavageDie.fromId("d4"), undefined);
#         equals(window.DiceRoller.SavageDie.fromId("4"), undefined);
#         equals(window.DiceRoller.SavageDie.fromId("-4"), undefined);
#         equals(window.DiceRoller.SavageDie.fromId("dF"), undefined);
#         equals(window.DiceRoller.SavageDie.fromId("xf5"), undefined);
#     });
# 
# };
