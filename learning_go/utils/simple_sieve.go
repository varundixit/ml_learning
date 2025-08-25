package utils

import (
	"math"
)

func SimpleSievePrime(n int) []int {
	var primes = make([]int, n)

	for i := 0; i < n; i++ {
		primes[i] = 1 // Assume all numbers are prime initially
	}
	primes[0] = 0 // 0 is not prime
	primes[1] = 0 // 1 is not prime
	for i := 2; i <= int(math.Sqrt(float64(n))); i++ {
		if primes[i] == 1 { // If i is prime
			for j := i * i; j < n; j += i {
				primes[j] = 0 // Mark multiples of i as not prime
			}
		}
	}
	var result []int
	for i := 2; i < n; i++ {
		if primes[i] == 1 {
			result = append(result, i) // Collect prime numbers
		}
	}
	return result
}

// SimpleSievePrime returns a slice of prime numbers less than n using the simple sieve algorithm.
// It initializes an array to mark prime numbers, iterates through potential primes,
// and marks their multiples as non-prime. Finally, it collects and returns the prime numbers.
// This is a basic implementation and may not be the most efficient for large n.
// It is suitable for educational purposes and small values of n.
// The function assumes n is a positive integer greater than 1.
// The time complexity is O(n log log n) and space complexity is O(n).
// Example usage:
// primes := SimpleSievePrime(30)
// fmt.Println(primes) // Output: [2 3 5 7 11 13 17 19 23 29]
// Note: This implementation is not optimized for very large n and is intended for educational purposes.
// It is a straightforward implementation of the simple sieve algorithm.
// It is not suitable for production use or large-scale prime number generation.
// The function is designed to be simple and easy to understand, focusing on clarity rather than performance.
// It can be used as a starting point for learning about prime number generation algorithms in Go.
// The function does not handle edge cases like negative inputs or non-integer values,
// as it is assumed that the input will always be a valid positive integer greater than 1.
