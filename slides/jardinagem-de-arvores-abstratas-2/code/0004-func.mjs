import { Instruction, interpreter } from "./bytecode.mjs"


// function sum() {
//   a = 2
//   return 40 + a
// }
// print(sum())
interpreter([
  Instruction.CALL, 7, 0,
  Instruction.PRIMITIVE, "print", 1,
  Instruction.HALT,
  // sum
  Instruction.PUSH, 2,
  Instruction.STORE, 0,
  Instruction.PUSH, 40,
  Instruction.LOAD, 0,
  Instruction.SUM,
  Instruction.RET,
], [
  undefined,
])
