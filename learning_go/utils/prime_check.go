package utils

import "math"

// IsPrime checks if a number is prime.
func IsPrime(n int) bool {
    if n <= 1 {
        return false
    }
    if n == 2 {
        return true
    }
    if n%2 == 0 {
        return false
    }

    // Check odd divisors up to sqrt(n)
    sqrtN := int(math.Sqrt(float64(n)))
    for i := 3; i <= sqrtN; i += 2 {
        if n%i == 0 {
            return false
        }
    }
    return true
}
