package main

import (
	"fmt"
	"learning_go/utils"
)

func main() {
	ab := utils.Sum(1, 2, 3, 4, 5)
	fmt.Println("Sum of 1, 2, 3, 4, 5 is:", ab)

	cd, err := utils.Average(10, 20, 30, 40)
	if err != nil {
		fmt.Println("Error calculating average:", err)
	} else {
		fmt.Println("Average of 10, 20, 30, 40 is:", cd)
	}

	ef, err := utils.SafeDivide(10, 2)
	if err != nil {
		fmt.Println("Error in division:", err)
	} else {
		fmt.Println("division result is:", ef)
	}
}
