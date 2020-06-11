package main

import (
	"math/big"
	"testing"
)

func TestCalculator(t *testing.T) {
	expression := "2+3"
	calc := &Calculator{Buffer: expression}
	calc.Init()
	calc.Expression.Init(expression)
	if err := calc.Parse(); err != nil {
		t.Fatal(err)
	}

	result := calc.Evaluate()

	if result.Cmp(big.NewInt(5)) != 0 {
		t.Fatalf("got incorrect result: %v", result)
	}
}
