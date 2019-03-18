#!/bin/sh

test_description='restore basic functionality'

. ./test-lib.sh

test_expect_success 'setup' '
	test_commit first &&
	echo first-and-a-half >>first.t &&
	git add first.t &&
	test_commit second &&
	echo one >one &&
	echo two >two &&
	echo untracked >untracked &&
	echo ignored >ignored &&
	echo /ignored >.gitignore &&
	git add one two .gitignore &&
	git update-ref refs/heads/one master
'

test_expect_success 'restore without pathspec is not ok' '
	test_must_fail git restore &&
	test_must_fail git restore --source=first
'

test_expect_success 'restore a file, ignoring branch of same name' '
	cat one >expected &&
	echo dirty >>one &&
	git restore one &&
	test_cmp expected one
'

test_expect_success 'restore a file on worktree from another branch' '
	test_when_finished git reset --hard &&
	git cat-file blob first:./first.t >expected &&
	git restore --source=first first.t &&
	test_cmp expected first.t &&
	git cat-file blob HEAD:./first.t >expected &&
	git show :first.t >actual &&
	test_cmp expected actual
'

test_expect_success 'restore a file in the index from another branch' '
	test_when_finished git reset --hard &&
	git cat-file blob first:./first.t >expected &&
	git restore --source=first --index first.t &&
	git show :first.t >actual &&
	test_cmp expected actual &&
	git cat-file blob HEAD:./first.t >expected &&
	test_cmp expected first.t
'

test_expect_success 'restore a file in both the index and worktree from another branch' '
	test_when_finished git reset --hard &&
	git cat-file blob first:./first.t >expected &&
	git restore --source=first --index --worktree first.t &&
	git show :first.t >actual &&
	test_cmp expected actual &&
	test_cmp expected first.t
'

test_expect_success 'restore --index uses HEAD as source' '
	test_when_finished git reset --hard &&
	git cat-file blob :./first.t >expected &&
	echo index-dirty >>first.t &&
	git add first.t &&
	git restore --index first.t &&
	git cat-file blob :./first.t >actual &&
	test_cmp expected actual
'

test_done
