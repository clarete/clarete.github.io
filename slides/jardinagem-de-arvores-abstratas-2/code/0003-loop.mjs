import { Instruction, interpreter } from "./bytecode.mjs"

// a = 0
// while (a < 10) {
//   print(a)
//   a++
// }
interpreter([
  Instruction.PUSH, 0,
  Instruction.STORE, 0,
  // loop
  Instruction.LOAD, 0,
  Instruction.PUSH, 10,
  Instruction.CMP,
  Instruction.JNB, 22,
  Instruction.LOAD, 0,
  Instruction.PRIMITIVE, "print", 1,
  Instruction.LOAD, 0,
  Instruction.INCR,
  Instruction.STORE, 0,
  Instruction.JMP, 4,
  // exit
  Instruction.HALT,
], [
  undefined,
]);
