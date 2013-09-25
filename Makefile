crash: crash.go calc.y
	go build -o crash crash.go

calc.y:
	cd scanner/calc; go tool yacc calc.y

clean:
	rm -f scanner/calc/y.go scanner/calc/y.output crash
