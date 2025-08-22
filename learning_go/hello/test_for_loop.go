package main

import (
	"fmt"
)

func main() {
	
	var i int;
	var num = 13;
	for i := 1; i <= 10; i++ {
		fmt.Printf("%d x %d = %d \n",num, i, num*i)
	}
	
	num = 17
	i = 1
	for i <= 10 {
		fmt.Printf("%d x %d = %d \n",num, i, num*i)
		i++
	}

	i = 1
	num = 23
	for {
		fmt.Printf("%d x %d = %d \n",num, i, num*i)
		i++
		if i >= 11 {
			break // avoid infinite loop here
		}
	}
}
