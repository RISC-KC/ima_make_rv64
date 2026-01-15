# ima_make_rv64
> I'ma make rv64 cpu.

## Introduction
This project is about making RISC-V RV64IMA Processor.  
Architecture is based on our previous project [basic_RV32s](https://github.com/RISC-KC/basic_rv32s/).  

## Roadmap

- RV64I59F_5SP  
  RV64I (52) + Zicsr (6) + mret (1) = 59
- RV64IZmmul64F_5SP  
  RV64I (52) + Zmmul (5) + Zicsr (6) + mret (1) = 64
- RV64IM72F_5SP  
  RV64I (52) + M (13) + Zicsr (6) + mret (1) = 72
- RV64IMA

## Benchmarks
### RV64I59F_5SP
- Dhrystone: 1.15 DMIPS/MHz @ 50MHz  
  <img width="652" height="1013" alt="Dhrystone_RV64I59F_5SP" src="https://github.com/user-attachments/assets/8acc627a-e18d-4b9e-8803-163c97732392" />

- Coremark: 0.92 Coremarks/MHz @ 50MHz  
  <img width="659" height="438" alt="Coremark_RV64I59F_5SP" src="https://github.com/user-attachments/assets/6a432f04-3ea9-4c6d-b657-8fc553a4fcff" />
