package bclock

import "core:fmt"
import "core:mem"
import "core:time"

// representation of digits in a binary clock
Bclock_Rep :: matrix[4, 2]u8

// debug function to print matrix
print_matrix :: proc(m: Bclock_Rep) {
	fmt.println("matrix[")
	for i in 0 ..= 3 {
		for j in 0 ..= 1 {
			fmt.print(m[i, j], " ")
		}
		fmt.println()
	}
	fmt.println("]")
}

// returns an array of the 10s 
// and 1s composing this integer
// 21 -> 2, 1
sep_digits :: proc(n: int) -> (a, b: int) {
	tens := (n / 10) % 10
	ones := n % 10
	return tens, ones
}


// "0" -> 0 
// "1" -> 1
bin_to_int :: proc(n: rune) -> u8 {
	switch n {
	case '1':
		return 1
	case '0':
		return 0
	case:
		panic("bin to int got non 0/1 rune")
	}
}


parse_single :: proc(i: int) -> (out: Bclock_Rep) {
	tens, ones := sep_digits(i)

	// format them into binary
	ts := fmt.aprintf("%b", tens)
	os := fmt.aprintf("%b", ones)

	// cleanup
	defer {
		delete(ts)
		delete(os)
	}

	// fill up the matrix
	index := 0
	#reverse for char in ts {
		out[3 - index, 0] = bin_to_int(char)
		index += 1
	}
	index = 0
	#reverse for char in os {
		out[3 - index, 1] = bin_to_int(char)
		index += 1
	}
	return
}

// parse time into 4 matrixes representing digits on 
// a binary clock
parse_time :: proc(t: time.Time) -> (h, m, s: Bclock_Rep) {
	hour, min, sec := time.clock_from_time(t)

	return parse_single(hour), parse_single(min), parse_single(sec)
}

main :: proc() {
	// tracking allocator
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	rn := time.now()
	fmt.println(rn)
	h, m, s := parse_time(rn)
	print_clock(h, m, s)
}
