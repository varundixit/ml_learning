package utils

import (
    "time"
)

// MeasureTime returns how long a function took
func MeasureTime(start time.Time) time.Duration {
    return time.Since(start)
}
