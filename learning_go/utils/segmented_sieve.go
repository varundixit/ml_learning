package utils

import (
	"math"
)

func SegmentedSievePrime(m int, n int) []int {
	if m < 2 {
		m = 2
	}

	limit := int(math.Sqrt(float64(n))) + 1
	basePrimes := SimpleSievePrime(limit)

	//fmt.Printf("Base primes for range [2, n] %d, %v:", limit, basePrimes)

	// Create a boolean array for the range [0, n - m + 1]
	len := n - m + 1
	isPrime := make([]bool, len) // +2 to handle the range [m, n] inclusively
	for i := range isPrime {
		isPrime[i] = true
	}

	// Use small primes to mark non-prime numbers in the range [2, n]
	for _, p := range basePrimes {
		firstMultiple := (m + p - 1) / p * p
		if firstMultiple < p*p {
			firstMultiple = p * p
		}

		for j := firstMultiple; j <= n; j += p {
			//fmt.Printf("Marking %d as non-prime\n", j-m)
			isPrime[j-m] = false
		}
	}

	// Collect all prime numbers from the boolean array
	var result []int
	for i, val := range isPrime {
		if val {
			result = append(result, i+m)
		}
	}
	return result
}
