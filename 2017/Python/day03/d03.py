import math

input = 265149

def part1(src):
    num = 1
    exp = 1
    dir = 0
    move = [ [ 1, 0 ], [ 0, -1 ], [ -1, 0 ], [ 0, 1 ] ]
    coord = [ 0, 0 ]
    while num < src:
        
        for i in range(exp):
            coord = [ coord[0] + move[dir][0], coord[1] + move[dir][1] ]
            num += 1
            if (num == src):
                break
        dir = (dir + 1) % 4
        if dir % 2 == 0:
            exp += 1
    return abs(coord[1] - 0) + abs(coord[0] - 0)

# All credit to https://oeis.org/A141481
# OEIS provided PARI/GP CAS code, which I converted to python
# And then modified it to find the answer rather than just print a sequence
# No I don't particularly understand it :^)
def part2(src):
    m = 5
    h = 2 * m - 1
    A = [[0 for i in range(h)] for j in range(h)]
    A[m-1][m-1] = 1
    T = [[1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1]]

    s = 0
    n = 1
    while s <= src:
        g = int(math.sqrt(n))
        r = (g + g % 2) // 2
        q = 4 * r ** 2
        d = n - q
        if n <= q - 2 * r:
            j = d + 3 * r
            k = r
        elif n <= q:
            j = r
            k = -d - r
        elif n <= q + 2 * r:
            j = r - d
            k = -r
        else:
            j = -r
            k = d - 3 * r
        j += m - 1
        k += m - 1
        s = 0
        for c in range(8):
            v = [j, k]
            v[0] += T[c][0]
            v[1] += T[c][1]
            if 0 <= v[0] < h and 0 <= v[1] < h:
                s += A[v[0]][v[1]]
        A[j][k] = s
        n += 1
    return s

print(part1(input))
print(part2(input))
