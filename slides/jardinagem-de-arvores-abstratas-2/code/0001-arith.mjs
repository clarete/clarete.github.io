import { Instruction, interpreter } from "./bytecode.mjs"

// 1 + 2 * 3 = 7
console.log(interpreter([
  Instruction.PUSH, 3,    // stack: [3]
  Instruction.PUSH, 2,    // stack: [3, 2]
  Instruction.MUL,        // stack: [6]
  Instruction.PUSH, 1,    // stack: [6, 1]
  Instruction.SUM,        // stack: [7]
  Instruction.HALT,
]));

// (1 + 2) * 3 = 9
console.log(interpreter([
  Instruction.PUSH, 2,    // stack: [2]
  Instruction.PUSH, 1,    // stack: [2, 1]
  Instruction.SUM,        // stack: [3]
  Instruction.PUSH, 3,    // stack: [3, 3]
  Instruction.MUL,        // stack: [9]
  Instruction.HALT,
]));
