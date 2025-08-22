package utils


func PrimeFactorSimplified(n int) []int {
    var factors []int
    divisor := 2

	// Handle negativity
	if n < 0 {
		factors = append(factors, -1)
		n = -n
	}

    for n > 1 {
        if n%divisor == 0 {
            factors = append(factors, divisor) // add divisor to slice
            n = n / divisor
        } else {
            divisor++
        }
    }
    return factors
}
