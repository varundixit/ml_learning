package main

import (
	"fmt"
	"learning_go/utils"
	"strconv"
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
	prime_slice = utils.PrimeFactors(favNumber)

	fmt.Printf("Hello %s, your favorite number is %s and it %s\n", name, number_type, prime)

	fmt.Printf("prime factors are %v\n", prime_slice)
	// TODO: Add logic to check if favNumber is even or odd
	// Hint: Use favNumber % 2 == 0 to check even
	// Then print something like:
	// "Hello, <name>! Your favorite number is even."
}
