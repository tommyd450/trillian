// Code generated by "stringer -type=Group quota.go"; DO NOT EDIT.

package quota

import "strconv"

func _() {
	// An "invalid array index" compiler error signifies that the constant values have changed.
	// Re-run the stringer command to generate them again.
	var x [1]struct{}
	_ = x[Global-0]
	_ = x[Tree-1]
	_ = x[User-2]
}

const _Group_name = "GlobalTreeUser"

var _Group_index = [...]uint8{0, 6, 10, 14}

func (i Group) String() string {
	if i < 0 || i >= Group(len(_Group_index)-1) {
		return "Group(" + strconv.FormatInt(int64(i), 10) + ")"
	}
	return _Group_name[_Group_index[i]:_Group_index[i+1]]
}