from dataclasses import dataclass
from enum import StrEnum

class FrameType(StrEnum):
    BACKTRACKING = 'BACKTRACKING'
    CALL = 'CALL'

@dataclass
class Frame:
    t: FrameType
    pc: int
    cursor: int

@dataclass
class Halt:
    pass

@dataclass
class Char:
    ch: str

@dataclass
class Choice:
    label: int

@dataclass
class Commit:
    label: int

@dataclass
class Call:
    label: int

@dataclass
class Return:
    pass

type Instruction = Halt | Char | Choice | Commit | Call | Return


class VirtualMachine:
    source: str = ""
    cursor: int = 0
    code: list[Instruction] = []
    pc: int = 0
    stack: list[Frame] = [] # stack frame

    def __init__(self, code, source):
        self.code = code
        self.source = source
        
    def run(self):
        while True:
            instruction = self.code[self.pc]
            print('pc', self.pc, 'cursor', self.cursor, repr(instruction))
            match instruction:
                case Halt():
                    break
                case Char(ch=ch):
                    current = self.source[self.cursor]
                    if current == ch:
                        self.cursor += 1
                        self.pc += 1
                        continue
                    self.fail()
                case Choice(label=label):
                    frame = Frame(t=FrameType.BACKTRACKING, pc=label, cursor=self.cursor)
                    self.stack.append(frame)
                    self.pc += 1
                case Commit(label=label):
                    self.stack.pop()
                    self.pc = label
                case Call(label=label):
                    frame = Frame(t=FrameType.CALL, pc=self.pc+1, cursor=self.cursor)
                    self.stack.push(frame)
                    self.pc = label
                case Return():
                    frame = self.stack.pop()
                    self.pc = frame.pc
        return

    def fail(self):
        while len(self.stack) > 0:
            frame = self.stack.pop()
            if frame.t == FrameType.BACKTRACKING:
                self.pc = frame.pc
                self.cursor = frame.cursor
                return
        raise Exception("Error!")


SheepProgram = [
    Char("b"),  # 00
    Choice(7),  # 01
    Choice(5),  # 02
    Char("a"),  # 03
    Commit(6),  # 04
    Char("e"),  # 05
    Commit(1),  # 06
    Char("h"),  # 07
    Halt(),     # 08
]


VirtualMachine(SheepProgram, "baah").run()
