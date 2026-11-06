input = [sorted(list(map(int, num))) for num in[row.split() for row in open('test2', 'r').read().splitlines()]]

def part1():
    return sum(max(row) - min(row) for row in input)

def part2():
    total = 0
    for row in input:
        loop = True
        for lo in row:
            for num in row[row.index(lo) + 1:]:
                if num % lo == 0:
                    total += int(num / lo)
                    loop = False
                    break
            if loop == False:
                break
    return total

print(part1())
print(part2())