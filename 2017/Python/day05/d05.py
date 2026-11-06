input = [int(i) for i in open('input', 'r').read().splitlines()]

def part1():
    instr = list(input)
    steps = 0
    idxa = 0
    while idxa < len(instr):
        idxb = idxa + instr[idxa]
        instr[idxa] += 1
        idxa = idxb
        steps += 1
    return steps

def part2():
    instr = list(input)
    steps = 0
    idxa = 0
    while idxa < len(instr):
        idxb = idxa + instr[idxa]
        if instr[idxa] < 3:
            instr[idxa] += 1
        else:
            instr[idxa] -= 1
        idxa = idxb
        steps += 1
    return steps

print(part1())
print(part2())