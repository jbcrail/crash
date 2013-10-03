all: query

query: query.rl
	ragel -Z -T1 -o $@.go $^

png:
	ragel -V query.rl > query.dot
	dot -Tpng query.dot > query.png

clean:
	rm -f query.go query.dot query.png
