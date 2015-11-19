package fizzbuzz // import "fizzbuzz"
import "strconv"

func FizzBuzz() <-chan string {
	c := make(chan string)
	go func() {
		for i := 1; i <= 100; i++ {
			if i%15 == 0 {
				c <- "fizzbuzz"
			} else if i%3 == 0 {
				c <- "fizz"
			} else if i%5 == 0 {
				c <- "buzz"
			} else {
				c <- strconv.Itoa(i)
			}
		}
		close(c)
	}()
	return c
}
