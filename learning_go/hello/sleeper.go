package main

import (
    "fmt"
    "time"
)

func main() {
    defer fmt.Println("First deferred")

    // Add some pauses
    time.Sleep(1 * time.Second)
    fmt.Println("...after 1 second")

    defer fmt.Println("Second deferred")
	
    // Add some pauses
    time.Sleep(2 * time.Second)
    fmt.Println("...after 2 second")
	
    defer fmt.Println("Third deferred")

    // Add some pauses
    time.Sleep(2 * time.Second)
    fmt.Println("...after 3 second")

    fmt.Println("Main function body")


    // When main ends, the deferred functions will execute (in LIFO order)
}
