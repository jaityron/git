#!/bin/sh

test_description='checkout --force'
. ./test-lib.sh

test_expect_success 'force checking out a conflict' '
	echo a >a &&
	git add a &&
	git commit -ama &&
	A_OBJ=$(git rev-parse :a) &&
	git branch topic &&
	echo b >a &&
	git commit -amb &&
	B_OBJ=$(git rev-parse :a) &&
	git checkout topic &&
	echo c >a &&
	C_OBJ=$(git hash-object a) &&
	git checkout -m master &&
	test_cmp_rev :1:a $A_OBJ &&
	test_cmp_rev :2:a $B_OBJ &&
	test_cmp_rev :3:a $C_OBJ &&
	git checkout -f topic &&
	test_cmp_rev :a $A_OBJ
'

test_done
