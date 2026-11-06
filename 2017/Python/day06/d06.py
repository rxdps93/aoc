input = [int(i) for i in open('input').read().split()]

def part1():
    states = set()
    state = tuple(input)
    while state not in states:
        states.add(state)
        state = list(state)
        num = max(state)
        idx = state.index(num)
        state[idx] = 0
        for i in range(1, num + 1):
            state[(idx + i) % len(state)] += 1
        state = tuple(state)

    return len(states)

def part2():
    states = set()
    state = tuple(input)
    while state not in states:
        states.add(state)
        state = list(state)
        num = max(state)
        idx = state.index(num)
        state[idx] = 0
        for i in range(1, num + 1):
            state[(idx + i) % len(state)] += 1
        state = tuple(state)

    return len(states) - list(states).index(state)

print(part1())
print(part2())