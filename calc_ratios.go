package main
import (
	"fmt"
	"sort"
	"math"
)
const MIN_TOOTH = 9
const MAX_TOOTH = 100

type ratio struct {
	a int
	b int
	c int
	d int
}

// This returns the sum of differences between the tooth count on each
// gear pair. This is used to minimise the size differences of the gears.
func (r *ratio) diff() int {
	return int(math.Abs(float64(r.a - r.b)) + math.Abs(float64(r.c - r.d)))
}

func calc_ratios(a int, b int) {
	results := make(map[ratio]bool)
	resired_ratio := float64(a) / float64(b)
	for i := MIN_TOOTH; i <= MAX_TOOTH; i++ {
		for j := MIN_TOOTH; j <= MAX_TOOTH; j++ {
			for k := MIN_TOOTH; k <= MAX_TOOTH; k++ {
				for l := MIN_TOOTH; l <= MAX_TOOTH; l++ {
					// Filter out any non-relatively-prime pairs
					if float64(i)/float64(j) - float64(i/j) == 0 || float64(k)/float64(l) - float64(k/l) == 0 {
						continue
					}
					if resired_ratio == (float64(i) / float64(j) * float64(k) / float64(l)) {
						if _, ok := results[ratio{k, l, i, j}]; !ok {
							results[ratio{i, j, k, l}] = true
						}
					}
				}
			}
		}
	}
	sortme := []ratio{}
	for r := range results {
		sortme = append(sortme, r)
	}
	sort.Slice(sortme, func(i, j int) bool {
			return sortme[i].diff() < sortme[j].diff()
		})
	for _, r := range sortme {
		fmt.Printf("%d:%d %d:%d\n", r.a, r.b, r.c, r.d)
	}
}

func main() {
	calc_ratios(1, 60)
}