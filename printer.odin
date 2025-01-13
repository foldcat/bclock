package bclock

// functions responsible of printing the binary clock itself

import "core:fmt"

// joins the 3 matrixes with ducttapes
// then fetch an item given an index 
grab_from_position :: proc(h, m, s: Bclock_Rep, row, col: int) -> u8 {
	switch col {
	case 0, 1:
		return h[row, col]
	case 2, 3:
		return m[row, col - 2]
	case 4, 5:
		return s[row, col - 4]
	case:
		panic("grab from position only works with index between 0 and 5 inclusively")
	}

}

print_clock :: proc(h, m, s: Bclock_Rep) {
	for row in 0 ..= 3 {
		for col in 0 ..= 5 {
			//fmt.print(row, col, " ", sep="")
			fmt.print(grab_from_position(h, m, s, row, col))
		}
		fmt.println()
	}
}
