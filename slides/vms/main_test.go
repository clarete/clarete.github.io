package main

import (
	"testing"
)

func TestIMovLitReg(t *testing.T) {
	m := NewMachine()
	m.RAM[0] = IMovLitReg
	m.RAM[1] = 0xAB
	m.RAM[2] = 0xCD
	m.RAM[3] = uint8(RegR1)
	m.RAM[4] = IHalt

	m.Run()

	reg := m.GetRegister(RegR1)

	if reg != 0xABCD {
		t.Errorf("RegR1 holds the wrong value: %d", reg)
	}
}

func TestIMovRegReg(t *testing.T) {
	m := NewMachine()

	m.SetRegister(RegR5, uint16(0xABCD))

	m.RAM[0] = IMovRegReg
	m.RAM[1] = uint8(RegR5)
	m.RAM[2] = uint8(RegR6)
	m.RAM[3] = IHalt

	m.Run()

	reg := m.GetRegister(RegR6)

	if reg != 0xABCD {
		t.Errorf("RegR6 holds the wrong value: %d", reg)
	}
}

func TestIMovRegMem(t *testing.T) {
	m := NewMachine()

	m.SetRegister(RegR5, uint16(0xABCD))

	m.RAM[0] = IMovRegMem
	m.RAM[1] = uint8(RegR5)
	m.RAM[2] = 0x00
	m.RAM[3] = 0xFA
	m.RAM[4] = IHalt

	m.Run()

	memVal := m.RAM.getUint16(0xFA)

	if memVal != 0xABCD {
		t.Errorf("Memory holds the wrong value: %d", memVal)
	}
}

func TestIMovMemReg(t *testing.T) {
	m := NewMachine()

	m.SetRegister(RegR5, uint16(0xABCD))

	m.RAM[0] = IMovMemReg
	m.RAM[1] = 0x00
	m.RAM[2] = 0xFA
	m.RAM[3] = uint8(RegR5)
	m.RAM[4] = IHalt

	m.RAM[0xFA] = 0xAB
	m.RAM[0xFB] = 0xCD

	m.Run()

	reg := m.GetRegister(RegR5)

	if reg != 0xABCD {
		t.Errorf("RegR5 holds the wrong value: %d", reg)
	}
}

func TestIAddRegReg(t *testing.T) {
	m := NewMachine()

	m.SetRegister(RegR1, uint16(0xFF))
	m.SetRegister(RegR2, uint16(0xDD))

	m.RAM[0] = IAddRegReg
	m.RAM[1] = uint8(RegR1)
	m.RAM[2] = uint8(RegR2)
	m.RAM[3] = IHalt

	m.Run()

	reg := m.GetRegister(RegAcc)

	if reg != uint16(0xFF + 0xDD) {
		t.Errorf("RegR5 holds the wrong value: %d", reg)
	}

}

func TestIJne(t *testing.T) {
	m := NewMachine()

	m.RAM[0x00] = IMovMemReg
	m.RAM[0x01] = 0x01
	m.RAM[0x02] = 0x00
	m.RAM[0x03] = uint8(RegR1)
	m.RAM[0x04] = IMovLitReg
	m.RAM[0x05] = 0x00
	m.RAM[0x06] = 0x01
	m.RAM[0x07] = uint8(RegR2)
	m.RAM[0x08] = IAddRegReg
	m.RAM[0x09] = uint8(RegR1)
	m.RAM[0x0A] = uint8(RegR2)
	m.RAM[0x0B] = IMovRegMem
	m.RAM[0x0C] = uint8(RegAcc)
	m.RAM[0x0D] = 0x01
	m.RAM[0x0E] = 0x00
	m.RAM[0x0F] = IJneLit
	m.RAM[0x10] = 0x00
	m.RAM[0x11] = 0x03
	m.RAM[0x12] = 0x00
	m.RAM[0x13] = 0x00
	m.RAM[0x14] = IHalt

	m.Run()

	reg := m.GetRegister(RegAcc)

	if reg != 3 {
		t.Errorf("RegAcc holds the wrong. Expected 3, actual: %d", reg)
	}
}
