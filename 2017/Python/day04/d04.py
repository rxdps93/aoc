input = [row.split() for row in open('input', 'r').read().splitlines()]

def part1():
    return [len(row[0]) == len(row[1]) for row in zip(input, [set(row) for row in input])].count(True)

def part2():
    return [len(row[0]) == len(row[1]) for row in zip(input, [list({''.join(sorted(word)) for word in row}) for row in input])].count(True)

print(part1())
print(part2())