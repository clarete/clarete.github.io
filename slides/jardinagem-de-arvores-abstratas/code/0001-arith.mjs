import { Instruction, interpreter } from "./bytecode.mjs"

// 1 + 2 * 3 = 7
console.log(interpreter([
  Instruction.PUSH, 3,
  Instruction.PUSH, 2,
  Instruction.MUL,
  Instruction.PUSH, 1,
  Instruction.SUM,
  Instruction.HALT,
]));

// (1 + 2) * 3 = 9
console.log(interpreter([
  Instruction.PUSH, 2,
  Instruction.PUSH, 1,
  Instruction.SUM,
  Instruction.PUSH, 3,
  Instruction.MUL,
  Instruction.HALT,
]));
