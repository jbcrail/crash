package main

import (
	"fmt"
    "./scanner/calc"

	"github.com/peterh/liner"
)

const (
	defaultPrompt = "crash# "
)

func main() {
	state := liner.NewLiner()
	defer state.Close()
	for {
		cmd, err := state.Prompt(defaultPrompt)
		if err != nil {
			fmt.Println(err)
			break
		}
		state.AppendHistory(cmd)
        if result, code := calc.Evaluate(cmd); code == 0 {
            fmt.Println(result)
        }
	}
}
