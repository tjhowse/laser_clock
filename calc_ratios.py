#!/usr/bin/python3

MIN_TOOTH = 11
MAX_TOOTH = 100

# This calculates two sets of two tooth counts to generate the overall
# gear ratio defined by a:b. The smallest tooth count will be MIN_TOOTH,
# the largest tooth count will be MAX_TOOTH.
def print_ratios(a: int, b: int):
    for i in range(MIN_TOOTH, MAX_TOOTH):
        for j in range(MIN_TOOTH, MAX_TOOTH):
            for k in range(MIN_TOOTH, MAX_TOOTH):
                for l in range(MIN_TOOTH, MAX_TOOTH):
                    if (i/j) * (k/l) == a/b or (i/j) * (k/l) == b/a:
                        print(f"{i}:{j} {k}:{l}")


print_ratios(60,1)