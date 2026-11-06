input = open('input', 'r').read().splitlines()

def part1(input):
    sum = 0
    for captcha in input:
        captcha += captcha[0]
        for i in range(0, len(captcha) - 1):
            if (captcha[i] == captcha[i + 1]):
                sum += int(captcha[i])
        print(sum)
        sum = 0

def part2(input):
    sum = 0
    for captcha in input:
        for i in range(0, len(captcha)):
            if (captcha[i] == captcha[int((i + (len(captcha) / 2)) % len(captcha))]):
                sum += int(captcha[i])
        print(sum)
        sum = 0

part1(input)
part2(input)