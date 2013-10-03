package main

import (
	"./fsm/query"
	"fmt"

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
		result, err := query.Parse(cmd + "\n")
		if err == nil {
			iterator := result.Iterator
			reducerOp := ""
			for _, op := range result.Ops {
				switch op.Name {
				case "take":
					iterator = iterator.Take(op.Args[0].(uint))
				case "drop":
					iterator = iterator.Drop(op.Args[0].(uint))
				case "max", "min", "last":
					reducerOp = op.Name
					break
				}
			}
			switch reducerOp {
			case "max":
				fmt.Println(iterator.Max())
			case "min":
				fmt.Println(iterator.Min())
			case "last":
				fmt.Println(iterator.Last())
			default:
				fmt.Println(iterator)
			}
		} else {
			fmt.Println(err)
		}
	}
}
