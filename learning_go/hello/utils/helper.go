package utils

import "fmt"

// SayHello is exported because it starts with a capital letter
func SayHello(name string) {
    fmt.Printf("Hello, %s! Welcome to Golang.\n", name)
}
