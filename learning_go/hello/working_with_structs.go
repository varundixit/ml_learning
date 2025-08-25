package main

import (
	"fmt"
	"math/rand"
)

func main() {
	type student struct {
		Name  string
		Age   int
		Score int
	}

	var StudentArray []student

	// Initialize the slice with some students
	for i := 0; i < 10; i++ {
		randomInt := rand.Intn(100) // Random integer between 0 and 99
		StudentArray = append(StudentArray, student{
			Name:  fmt.Sprintf("Student%d", i+1),
			Age:   20 + i,
			Score: randomInt,
		})
	}

	for i, val := range StudentArray {
		fmt.Printf("Student %d: Name: %s, Age: %d, Score: %d\n", i+1, val.Name, val.Age, val.Score)
	}
}
