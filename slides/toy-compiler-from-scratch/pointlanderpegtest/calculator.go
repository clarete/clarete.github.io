package main

import (
	"math/big"
)

type Type uint8

const (
	TypeNumber Type = iota
	TypeAdd
	TypeMultiply
)

type ByteCode struct {
	T     Type
	Value *big.Int
}

func (code *ByteCode) String() string {
	switch code.T {
	case TypeNumber:
		return code.Value.String()
	case TypeAdd:
		return "+"
	case TypeMultiply:
		return "*"
	}
	return ""
}

type Expression struct {
	Code []ByteCode
	Top  int
}

func (e *Expression) Init(expression string) {
	e.Code = make([]ByteCode, len(expression)*2+1)
}

func (e *Expression) AddOperator(operator Type) {
	code, top := e.Code, e.Top
	e.Top++
	code[top].T = operator
}

func (e *Expression) AddValue(value string) {
	code, top := e.Code, e.Top
	e.Top++
	code[top].Value = new(big.Int)
	code[top].Value.SetString(value, 10)
}

func (e *Expression) Evaluate() *big.Int {
	stack, top := make([]big.Int, len(e.Code)), 0
	for _, code := range e.Code[0:e.Top] {
		// fmt.Printf("Aqui se faz, aqui se paga %#v\n", e.Code)
		switch code.T {
		case TypeNumber:
			stack[top].Set(code.Value)
			top++
			continue
		}
		a, b := &stack[top-2], &stack[top-1]
		top--
		switch code.T {
		case TypeAdd:
			a.Add(a, b)
		case TypeMultiply:
			a.Mul(a, b)
		}
	}
	return &stack[0]
}
