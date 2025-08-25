package main

import (
	"fmt"
	"learning_go/utils"
)

func main() {
	var arr [25]int // [0 0 0]

	num_list := utils.SimpleSievePrime(100)
	for index, value := range num_list {
		arr[index] = value
	}
	fmt.Println("from the fixed length array", arr) // [10 20 30]

	var nums []int // empty slice
	nums = utils.SegmentedSievePrime(100000000, 999999999)
	fmt.Println("from the varied length", len(nums))

}
