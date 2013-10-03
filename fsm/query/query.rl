/*
 * Convert a string to an integer.
 */

package query;

import (
    "errors"
    "fmt"

    F "github.com/tcard/functional"
)

%%{
	machine query;
	write data;
}%%

type Op struct {
    Name string
    Args []interface{}
}

type Query struct {
    Iterator *F.Thunk
    Ops []*Op
}

func Parse(data string) (*Query, error) {
    var val uint
    cs, p, pe := 0, 0, len(data)

    stackNums := make([]uint, 0)
    query := new(Query)

    var xrange func(uint, uint) *F.Thunk
    xrange = func(a uint, z uint) *F.Thunk {
        if a > z {
            return F.Empty
        } else {
            return F.DelayedLink(a, func() *F.Thunk { return xrange(a + 1, z) })
        }
    }

	%%{
        action reset {
            val = 0
        }

        action dgt {
            val *= 10
            val = val + uint(fc) - uint('0')
        }

        action store {
            stackNums = append(stackNums, val)
        }

		action range { 
            upper := stackNums[len(stackNums)-1]
            stackNums = stackNums[:len(stackNums)-1]
            lower := stackNums[len(stackNums)-1]
            stackNums = stackNums[:len(stackNums)-1]
            query.Iterator = xrange(lower, upper)
		}

        action drop {
            n := stackNums[len(stackNums)-1]
            stackNums = stackNums[:len(stackNums)-1]
            op := new(Op)
            op.Name = "drop"
            op.Args = append(op.Args, n)
            query.Ops = append(query.Ops, op)
        }

        action take {
            n := stackNums[len(stackNums)-1]
            stackNums = stackNums[:len(stackNums)-1]
            op := new(Op)
            op.Name = "take"
            op.Args = append(op.Args, n)
            query.Ops = append(query.Ops, op)
        }

        action max {
            op := new(Op)
            op.Name = "max"
            query.Ops = append(query.Ops, op)
        }

        action min {
            op := new(Op)
            op.Name = "min"
            query.Ops = append(query.Ops, op)
        }

        action last {
            op := new(Op)
            op.Name = "last"
            query.Ops = append(query.Ops, op)
        }

        whitespace = [ \t]*;
        number = ( [0-9]+ @dgt ) >reset %store;
        value = number whitespace;
        pipe = '|' whitespace;

        open = '[' whitespace;
        close = ']' whitespace;
        rangeOp = ".." whitespace;
        range  = open value rangeOp value close %range;

        takeOp = "take" whitespace;
        take = takeOp value %take;

        dropOp = "drop" whitespace;
        drop = dropOp value %drop;

        maxOp = "max" whitespace;
        max = maxOp %max;

        minOp = "min" whitespace;
        min = minOp %min;

        lastOp = "last" whitespace;
        last = lastOp %last;

        main := range (pipe take | pipe drop)* (pipe max | pipe min | pipe last)? . '\n';

		# Initialize and execute.
		write init;
		write exec;
	}%%

    if cs < query_first_final {
        if p == pe {
            return nil, errors.New(fmt.Sprintf("unexpected eof: %s", data))
        } else {
            return nil, errors.New(fmt.Sprintf("error at pos %d: %s", p, data))
        }
    }

    return query, nil
}
