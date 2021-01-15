package main

import "fmt"

const RAM = 256*256

type MachineState uint8

const (
	MachineStateHalt MachineState = iota
	MachineStateError
	MachineStateContinue
	MachineStateStep
)

type Register uint8

const (
	RegAcc Register = iota
	RegPC
	RegSP
	RegFP
	RegR1
	RegR2
	RegR3
	RegR4
	RegR5
	RegR6
	RegR7
	RegR8
	_RegSentinel
)

const (
	IHalt uint8 = iota

	IMovLitReg
	IMovRegReg
	IMovRegMem
	IMovMemReg

	IAddRegReg

	IJneLit
)

type Memory []uint8

func (m *Memory) getUint8(index uint16) uint8 {
	return (*m)[index]
}

func (m *Memory) getUint16(index uint16) uint16 {
	return (uint16((*m)[index])<<8 |
		uint16((*m)[index+1]))
}

func (m *Memory) setUint8(index uint16, value uint8) {
	(*m)[index] = value
}

func (m *Memory) setUint16(index, value uint16) {
	(*m)[index] = uint8(value >> 8)
	(*m)[index+1] = uint8(value & 0xFF)
}

type Machine struct {
	Registers Memory
	RAM       Memory
}

func NewMachine() *Machine {
	return &Machine{
		Registers: make(Memory, _RegSentinel * 2),
		RAM:       make(Memory, RAM),
	}
}

func (m *Machine) SetRegister(r Register, value uint16) {
	m.Registers.setUint16(uint16(r) * 2, value)
}

func (m *Machine) GetRegister(r Register) uint16 {
	return m.Registers.getUint16(uint16(r) * 2)
}

func (m *Machine) Fetch() uint8 {
	pc := m.GetRegister(RegPC)
	value := m.RAM.getUint8(pc)
	m.SetRegister(RegPC, pc+1)
	return value
}

func (m *Machine) Fetch16() uint16 {
	pc := m.GetRegister(RegPC)
	value := m.RAM.getUint16(pc)
	m.SetRegister(RegPC, pc+2)
	return value
}

func (m *Machine) FetchReg() Register {
	return Register(m.Fetch() % uint8(_RegSentinel))
}

func (m *Machine) Step() MachineState {
	switch m.Fetch() {
	case IHalt:
		fmt.Printf("IHalt\n")
		return MachineStateHalt

	case IMovLitReg:
		lit := m.Fetch16()
		reg := m.FetchReg()
		m.SetRegister(reg, lit)
		fmt.Printf("IMovLitReg 0x%X %d\n", lit, reg)

	case IMovRegReg:
		regFrom := m.FetchReg()
		regTo := m.FetchReg()
		m.SetRegister(regTo, m.GetRegister(regFrom))
		fmt.Printf("IMovRegReg %d %d\n", regFrom, regTo)

	case IMovRegMem:
		regFrom := m.FetchReg()
		address := m.Fetch16()
		m.RAM.setUint16(address, m.GetRegister(regFrom))
		fmt.Printf("IMovRegMem %d 0x%04X\n", regFrom, address)

	case IMovMemReg:
		address := m.Fetch16()
		regTo := m.FetchReg()
		m.SetRegister(regTo, m.RAM.getUint16(address))
		fmt.Printf("IMovMemReg 0x%04X %d\n", address, regTo)

	case IAddRegReg:
		regA := m.FetchReg()
		regB := m.FetchReg()
		m.SetRegister(RegAcc, m.GetRegister(regA) + m.GetRegister(regB))
		fmt.Printf("IAddRegReg %d %d (ACC: %d)\n", regA, regB, m.GetRegister(RegAcc))

	case IJneLit:
		lit := m.Fetch16()
		address := m.Fetch16()
		if m.GetRegister(RegAcc) != lit {
			m.SetRegister(RegPC, address)
		}
		fmt.Printf("IJneLit    0x%04X 0x%04X\n", lit, address)

	default:
		panic("Unknown instruction")
		return MachineStateError
	}

	return MachineStateStep
}

func (m *Machine) Run() {
	for {
		switch m.Step() {
		case MachineStateHalt:
			return
		case MachineStateContinue:
			continue
		case MachineStateStep:
			continue
		default:
			panic("Unhandled machine state")
		}
	}
}

func main() {
	m := NewMachine()

	m.RAM[0] = IHalt

	m.Run()
}
