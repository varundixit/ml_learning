package utils

import "errors"

func Sum(nums ...int) int {
	if len(nums) == 0 {
		return 0
	}
	sum := 0
	for _, num := range nums {
		sum += num
	}
	return sum
}

func Average(nums ...int) (float64, error) {

	if len(nums) == 0 {
		return 0, errors.New("cannot average empty slice")
	}

	sum := 0
	for _, num := range nums {
		sum += num
	}

	return float64(sum) / float64(len(nums)), nil
}

func SafeDivide(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("cannot divide by zero")
	}
	return a / b, nil
}
