crash: crash.go query.rl
	go build -o crash crash.go

query.rl:
	cd fsm/query ; make

clean:
	cd fsm/query ; make clean
	rm -f crash
