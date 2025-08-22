package main

import (
	"fmt"
	"learning_go/utils"
	"strconv"
	"time"
)

func main() {
	var name string
	var favNumberStr string

	// Ask for name
	fmt.Print("What is your name? ")
	fmt.Scanln(&name)

	// Ask for favorite number
	fmt.Print("What is your favorite number? ")
	fmt.Scanln(&favNumberStr)

	// Convert string to integer
	favNumber, err := strconv.Atoi(favNumberStr)
	if err != nil {
		fmt.Println("That's not a valid number!")
		return
	}

	number_type := utils.Parity(favNumber)

	var prime string
	switch utils.IsPrime(favNumber) {
	case true:
		prime = "is prime"
	default:
		prime = "is not prime"
	}

	var prime_slice []int
	var simplified_prime_slice []int
	var elapsed1 time.Duration
	var elapsed2 time.Duration

	//defer func(start1 time.Time) {elapsed1 = utils.MeasureTime(start1)}(time.Now())
	start1 := time.Now() // record start time
	prime_slice = utils.PrimeFactors(favNumber)
	elapsed1 = time.Since(start1) // calculate elapsed time
	
	//defer func(start2 time.Time) {elapsed2 = utils.MeasureTime(start2)}(time.Now())	
	start2 := time.Now() // record start time
	simplified_prime_slice = utils.PrimeFactorSimplified(favNumber)
	elapsed2 = time.Since(start2) // calculate elapsed time

	fmt.Printf("Hello %s, your favorite number is %s and it %s\n", name, number_type, prime)

	fmt.Printf("It took %s to calculate the prime factors %v\n", elapsed1, prime_slice)
	fmt.Printf("It took %s to calculate the prime factors %v\n", elapsed2, simplified_prime_slice)
}
