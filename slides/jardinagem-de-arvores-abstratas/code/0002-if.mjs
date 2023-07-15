import { Instruction, interpreter } from "./bytecode.mjs"

// if (a == b) {
//   print("oi!")
// }
interpreter([
  Instruction.PUSH, 1,
  Instruction.PUSH, 1,
  Instruction.CMP,
  Instruction.JNE, 12,
  Instruction.PUSH, "oi!",
  Instruction.PRIMITIVE, "print", 1,
  Instruction.HALT,
]);
