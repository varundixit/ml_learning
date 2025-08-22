package main

import (
	"fmt"
	"strings"
)

func main() {
	
	CounterVowels := 0
	CounterConsonants := 0
	CounterOthers := 0
	
	Vowels := "aeiouAEIOU"

	str := "Hello there I am using Go here"
	for _, ch := range str {

		if strings.ContainsRune(Vowels, ch) {
			CounterVowels++
		} else if (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') {
			CounterConsonants++
		} else {
			CounterOthers++
		}
	}
	fmt.Printf("count of Vowels: %d \n count of Consonants: %d \n count of others: %d ", CounterVowels, CounterConsonants, CounterOthers)

}
