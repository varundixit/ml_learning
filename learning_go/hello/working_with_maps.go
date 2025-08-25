package main

import (
	"fmt"
)

func main() {
	scores := make(map[string]int)
	scores["Alice"] = 90
	scores["Bob"] = 80
	scores["Charlie"] = 70
	fmt.Println(scores) // map[Alice:90 Bob:80]

	val, exists := scores["Pingduo"]
	if exists {
		fmt.Println("Pingduo:", val)
	} else {
		fmt.Println("Pingduo not found")
	}

	for name, score := range scores {
		fmt.Printf("%s → %d\n", name, score)
	}

}
