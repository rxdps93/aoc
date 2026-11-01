# 2021 Day 24 Input Analysis

Register state will be printed as `[w x y z]`.

Goal is to have a zero in register Z. Any other value is considered a failure.

What is the largest input possible that results in that 0?

## Input Block 1 (A)

```
registers:      [w  x  y  z]
init        ->  [0  0  0  0]
inp w       ->  [A  0  0  0]
mul x 0     ->  [A  0  0  0]
add x z     ->  [A  0  0  0]
mod x 26    ->  [A  0  0  0]
div z 1     ->  [A  0  0  0]
add x 11    ->  [A 11  0  0]
eql x w     ->  [A  0  0  0] will always be 0
eql x 0     ->  [A  1  0  0] will always be 1
mul y 0     ->  [A  1  0  0]
add y 25    ->  [A  1 25  0]
mul y x     ->  [A  1 25  0]
add y 1     ->  [A  1 26  0]
mul z y     ->  [A  1  0  0]
mul y 0     ->  [A  1  0  0]
add y w     ->  [A  1  A  0]
add y 1     ->  [A  1 A+1 0]
mul y x     ->  [A  1 A+1 0]
add z y     ->  [A  1 A+1 A+1]
```

## Input Block 2 (B)
This input block's instructions begin as identical to input block 1 but branch off towards the end.
```
registers:      [w  x  y   z ]
init        ->  [A  1 A+1 A+1]
inp w       ->  [B  1 A+1 A+1]
mul x 0     ->  [B  0 A+1 A+1]
add x z     ->  [B A+1 A+1 A+1]
mod x 26    ->  [B (A+1)%26 A+1 A+1]
div z 1     ->  [B (A+1)%26 A+1 A+1]
add x 11    ->  [B ((A+1)%26)+11 A+1 A+1]
eql x w     ->  [B  0 A+1 A+1] will always be 0
eql x 0     ->  [B  1 A+1 A+1] will always be 1
mul y 0     ->  [B  1  0  A+1]
add y 25    ->  [B  1 25  A+1]
mul y x     ->  [B  1 25  A+1]
add y 1     ->  [B  1 26  A+1]
mul z y     ->  [B  1 26  26(A+1)]
mul y 0     ->  [B  1  0  26(A+1)]
add y w     ->  [B  1  B  26(A+1)]
add y 11    ->  [B  1  B+11 26(A+1)] first different instruction.
mul y x     ->  [B  1  B+11 26(A+1)]
add z y     ->  [B  1  B+11 26(A+1) + (B+11)]
```

## Observations
1. Patterns related to dividing z by a value (`div z ?`):
    - Half of the time we divide by 1, the other half is by 26.
    - This value indirectly determines the outcome of the following 2 `eql` instructions (meaning x will either be 1 or 0)
    - This value relates to the second observation.

2. Patterns related to adding to x immediately prior to the two `eql` instructions:
    - If we divided z by 1 we add a positive value.
    - If we divided z by 26 we add a negative value.
    - This value heavily influences the following 2 `eql` instructions (leading x to be either a 1 or a 0)

3. Patterns related to the number 26:
    - Every block performs `mod x 26`
    - In context, we do `mul x 0; add x z` first, meaning we are in essence doing the operation to the value of z that carried over from the previous block.
    - In the event that z was multiplied by 26 (which could happen depending on the outcome of previous operations) this would grab the right-most digit and store it into x.
    - In a similar vein, if our `div z ?` is dividing by 26 and our z was multiplied by 26, then we would be dropping the right-most digit and storing what's left in z.
    - Putting these 2 together we are dividing the value of z, storing the result in z and the remainder in x.

| Block # | `div z ? ` | `add x ?` | `add y ?` | Result      | Always Push | Only Pop   |
| ------- | :--------: | :-------: | :-------: | :---------: | :---------: | :--------: |
|  1      | 1          | 11        |1          | Push        | + 1         | + 1        |
|  2      | 1          | 11        |11         | Push        | + 2         | + 2        |
|  3      | 1          | 14        |1          | Push        | + 3         | + 3        |
|  4      | 1          | 11        |11         | Push        | + 4         | + 4        |
|  5      | 26         | -8        |2          | Push or Pop | + 5         | + 3        |
|  6      | 26         | -5        |9          | Push or Pop | + 6         | + 2        |
|  7      | 1          | 11        |7          | Push        | + 7         | + 3        |
|  8      | 26         | -13       |11         | Push or Pop | + 8         | + 2        |
|  9      | 1          | 12        |6          | Push        | + 9         | + 3        |
| 10      | 26         | -1        |15         | Push or Pop | +10         | + 2        |
| 11      | 1          | 14        |7          | Push        | +11         | + 3        |
| 12      | 26         | -5        |1          | Push or Pop | +12         | + 2        |
| 13      | 26         | -4        |8          | Push or Pop | +13         | + 1        |
| 14      | 26         | -8        |6          | Push or Pop | +14         | + 0        |

Note: "Only Pop" means that we do not push to the stack. In those blocks something is always popped, but there is a chance that something does not get pushed afterwards.


## Input Block 3 (C)

```
registers:      [w  x  y    z]
init        ->  [B  1  B+11 26(A+1) + (B+11)]
inp w       ->  [C  1  B+11 26(A+1) + (B+11)]
mul x 0     ->  [C  0  B+11 26(A+1) + (B+11)]
add x z     ->  [C  z  B+11 26(A+1) + (B+11)]
mod x 26    ->  [C  z%26 B+11 26(A+1) + (B+11)]
div z 1     ->  [C  z%26 B+11 26(A+1) + (B+11)]
add x 14    ->  [C (z%26)+14 B+11 26(A+1) + (B+11)]
eql x w     ->  [C  0  B+11 26(A+1) + (B+11)]
eql x 0     ->  [C  1  B+11 26(A+1) + (B+11)]
mul y 0     ->  [C  1  0  26(A+1) + (B+11)]
add y 25    ->  [C  1 25  26(A+1) + (B+11)]
mul y x     ->  [C  1 25  26(A+1) + (B+11)]
add y 1     ->  [C  1 26  26(A+1) + (B+11)]
mul z y     ->  [C  1 26  26(26(A+1) + (B+11))]
mul y 0     ->  [C  1  0  26(26(A+1) + (B+11))]
add y w     ->  [C  1  C  26(26(A+1) + (B+11))]
add y 1     ->  [C  1 C+1 26(26(A+1) + (B+11))]
mul y x     ->  [C  1 C+1 26(26(A+1) + (B+11))]
add z y     ->  [C  1 C+1 26(26(A+1) + (B+11)) + (C+1)]
```

It appears the pattern that is forming is something like this:
```c
int input = (the current blocks input value)
int a = (the ? in add y ?)
int b = (the ? in div z ?)
int c = (the ? in add x ?)

reg[x] = reg[z] % 26 // should be prev block's input + prev block's "a"
if (b == 1) {
    // register x becomes 1
} else { // only other option is 26
    // register x could be 1 or 0

}

// "push" input + a to the stack (reg[z])
```
I will refine this pseudocode further after further block analysis.

## Input Block 4 (D)

```
registers   ->  [w  x  y  z]
init        ->  [C  1 C+1 26(26(A+1) + (B+11)) + (C+1)]
inp w       ->  [D  1 C+1 26(26(A+1) + (B+11)) + (C+1)]
mul x 0     ->  [D  0 C+1 26(26(A+1) + (B+11)) + (C+1)]
add x z     ->  [D  z C+1 26(26(A+1) + (B+11)) + (C+1)]
mod x 26    ->  [D z%26 C+1 26(26(A+1) + (B+11)) + (C+1)]
div z 1     ->  [D z%26 C+1 26(26(A+1) + (B+11)) + (C+1)]
add x 11    ->  [D (z%26)+11 C+1 26(26(A+1) + (B+11)) + (C+1)]
eql x w     ->  [D  0 C+1 26(26(A+1) + (B+11)) + (C+1)]
eql x 0     ->  [D  1 C+1 26(26(A+1) + (B+11)) + (C+1)]
mul y 0     ->  [D  1  0  26(26(A+1) + (B+11)) + (C+1)]
add y 25    ->  [D  1 25  26(26(A+1) + (B+11)) + (C+1)]
mul y x     ->  [D  1 25  26(26(A+1) + (B+11)) + (C+1)]
add y 1     ->  [D  1 26  26(26(A+1) + (B+11)) + (C+1)]
mul z y     ->  [D  1 26  26(26(26(A+1) + (B+11)) + (C+1))]
mul y 0     ->  [D  1  0  26(26(26(A+1) + (B+11)) + (C+1))]
add y w     ->  [D  1  D  26(26(26(A+1) + (B+11)) + (C+1))]
add y 11    ->  [D  1 D+11 26(26(26(A+1) + (B+11)) + (C+1))]
mul y x     ->  [D  1 D+11 26(26(26(A+1) + (B+11)) + (C+1))]
add z y     ->  [D  1 D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
```

## Input Block 5 (E)
This is important as it represents our first negative value scenario.

```
registers       [w  x  y   z]
init        ->  [D  1 D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
inp w       ->  [E  1 D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
mul x 0     ->  [E  0 D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
add x z     ->  [E  z D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
mod x 26    ->  [E z%26 D+11 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)]
div z 26    ->  [E z%26 D+11 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add x -8    ->  [E (z%26)-8 D+11 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
eql x w     ->  [E 1|0 D+11 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
eql x 0     ->  [E 1|0 D+11 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
mul y 0     ->  [E 1|0  0  26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add y 25    ->  [E 1|0 25  26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
mul y x     ->  [E 1|0 25|0 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add y 1     ->  [E 1|0 26|1 26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
mul z y     ->  [E 1|0 26|1 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
mul y 0     ->  [E 1|0   0 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add y w     ->  [E 1|0   E 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add y 2     ->  [E 1|0  E+2 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
mul y x     ->  [E 1|0 E+2|0 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
add z y     ->  [E 1|0 E+2|0 26(26(26(A+1) + (B+11)) + (C+1)) + (D+11) + (E+2)|26(26(A+1) + (B+11)) + (C+1) + (D+11)/26]
```

This demonstrates that when we perform `div z 26` and thus `add x -?` we could either evaluate, through the 2 `eql` instructions, register x to be 1 or 0. This will carry throughout the block and result in the input+? (from `add y ?`) being pushed to z (in the case of reg[x]=1) or ignored (in the 0 case).

## Conclusions

Given the behavior of register Z, the goal is to always "pop" from it when possible. There are 7 sets of inputs where something will always be "pushed" to register Z, but there are also 7 inputs where something can possibly NOT be pushed. Therefore, in order go guarantee a 0 in register Z we need to ensure NOTHING is remaining in the "stack" by the end of the program. This is accomplished by ensuring that, in each of the 7 "poppable" input blocks (containing `div z 26`), the input results in the two `eql` instructions leaving register X with a value of 0 in it.

The analysis so far leaves me with these thoughts towards optimizing a solution:

1. In an input block where `div z 26` is present we always pop, and then have a chance of either pushing or not pushing.
2. Each pop block is paired with a previous block that pushed something.
3. That previous "pair" block cannot be assumed to be block immediately preceding because that could have been a pop block
4. The choice to push or not push depends on the current and paired block input value.
5. The choice ALSO depends on the paired blocks `add y ?` value and the current block's `add x ?` value
6. In order to determine a pop/push block's ideal input we need to figure out the paired block's input value.
7. Because the 14 blocks act in 7 pairs, it can be assumed that the pairs don't interact with each other.
8. The solution is to identify the pairs and then find the largest combination of input digits that satisfies the conditions (e.g. evaluates to a pop given the y and x values)

## Identifying Pairs

Using the table above...
| Block # | `div z ? ` | `add x ?` | `add y ?` | Input... | Result | Z Contents |
| ------- | :--------: | :-------: | :-------: | :------: | :----: | :--------: |
|  1      | 1          | 11        |1          | A        | Push A | A          |
|  2      | 1          | 11        |11         | B        | Push B | BA         |
|  3      | 1          | 14        |1          | C        | Push C | CBA        |
|  4      | 1          | 11        |11         | D        | Push D | DCBA       |
|  5      | 26         | -8        |2          | E        | Pop D  | CBA        |
|  6      | 26         | -5        |9          | F        | Pop C  | BA         |
|  7      | 1          | 11        |7          | G        | Push G | GBA        |
|  8      | 26         | -13       |11         | H        | Pop G  | BA         |
|  9      | 1          | 12        |6          | I        | Push I | IBA        |
| 10      | 26         | -1        |15         | J        | Pop I  | BA         |
| 11      | 1          | 14        |7          | K        | Push K | KBA        |
| 12      | 26         | -5        |1          | L        | Pop K  | BA         |
| 13      | 26         | -4        |8          | M        | Pop B  | A          |
| 14      | 26         | -8        |6          | N        | Pop A  | 0          |

1. Block  1 & Block 14
2. Block  2 & Block 13
3. Block  3 & Block  6
4. Block  4 & Block  5
5. Block  7 & Block  8
6. Block  9 & Block 10
7. Block 11 & Block 12

## Analyzing Pairs

In this table, the "push" digit will be referred to as A and the "pop" digit will be B, each pair will have an "A" and a "B."
| Push Block | Pop Block | Relationship | Simplified |  B  |  A  |
| :--------: | :-------: | :----------: | :--------: | :-: | :-: |
|  1         | 14        | B == A+1-8   | B == A - 7 |  2  |  9  |
|  2         | 13        | B == A+11-4  | B == A + 7 |  9  |  2  |
|  3         |  6        | B == A+1-5   | B == A - 4 |  5  |  9  |
|  4         |  5        | B == A+11-8  | B == A + 3 |  9  |  6  |
|  7         |  8        | B == A+7-13  | B == A - 6 |  3  |  9  |
|  9         | 10        | B == A+6-1   | B == A + 5 |  9  |  4  |
| 11         | 12        | B == A+7-5   | B == A + 2 |  9  |  7  |

Thus the serial number for part 1 should be
9 2 9 6 9 5 9 3 4 9 7 9 9 2

## Part 2

This should be the same as above except with the assuming being start with 1 vs 9:

| Push Block | Pop Block | Relationship | Simplified |  B  |  A  |
| :--------: | :-------: | :----------: | :--------: | :-: | :-: |
|  1         | 14        | B == A+1-8   | B == A - 7 |  1  |  8  |
|  2         | 13        | B == A+11-4  | B == A + 7 |  8  |  1  |
|  3         |  6        | B == A+1-5   | B == A - 4 |  1  |  5  |
|  4         |  5        | B == A+11-8  | B == A + 3 |  4  |  1  |
|  7         |  8        | B == A+7-13  | B == A - 6 |  1  |  7  |
|  9         | 10        | B == A+6-1   | B == A + 5 |  6  |  1  |
| 11         | 12        | B == A+7-5   | B == A + 2 |  3  |  1  |

Thus the serial number for part 2 should be
8 1 5 1 4 1 7 1 1 6 1 3 8 1