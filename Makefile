.PHONY: install compile test run format

MIX?=mix


install:
	noop

compile:
	$(MIX) do deps.get, deps.compile, compile

format:
	$(MIX) format

test: format
	$(MIX) test

run:
	$(MIX) run --no-halt
