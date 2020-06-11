PEG=~/.asdf/installs/golang/1.13.4/packages/bin/peg

.SUFFIXES: .peg .go

.peg.go:
	$(PEG) -noast -switch -inline -strict -output $@ $<

all: grammar.go
