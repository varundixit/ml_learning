package utils

import (
	"math"
)

func PrimeFactors(n int) []int {
	var factors []int

	// Handle negativity
	if n < 0 {
		factors = append(factors, -1)
		n = -n
	}

	// Handle factor 2
	for n%2 == 0 {
		factors = append(factors, 2)
		n /= 2
	}

	// Handle odd factors
	for i := 3; i <= int(math.Sqrt(float64(n))); i += 2 {
		for n%i == 0 {
			factors = append(factors, i)
			n /= i
		}
	}

	// Remaining prime
	if n > 1 {
		factors = append(factors, n)
	}

	return factors
}
