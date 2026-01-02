# RV64I 확장
## [2025.12.22.]
basic_RV32s의 v2.0.0 release를 마치고 RV64I 확장으로 넘어왔다.  
기존 basic_RV32s에서 진행했던 RV64 설계 로그를 가져와보겠다. 

[RV64s]  

-----
RV64I59F : RV64I Extension  
└ 47F + RV64I  

RV64I59F_5SP  
└ 59F + 5-Stage Pipeline  

RV64IM72F : M extension supported. Maybe Grapchics Interface from this architecture.   
└ 59F5SP + RV64M  

[Final]  
RV32IMA104_CMO_RVWMO : A extension supported.   
└ Full RV64I + RV64M + RV64A + Zicsr + Zifencei + mret + CMO + RVWMO    

▶ Fully supports RV32I. Including FENCE, FENCE.TSO, PAUSE after all.  
▶ Complies RVWMO memory consistancy model.   
▶ Dual-Core (multi-hart) processing system.  
▶ Improved Cache structure  
 ├ Two separate L1 Cache 	; Instruction Cache, Data Cache respectively.  
 ├ One integrated L2 Cache 	; Integrated Cache that contains Instructions and Datas.  
 └ One shared L3 Cache		; A Cache that shared by each core(hart).  
 
 L1$, L2$ for each core respectively, L3$ is shared cache that all the core can access.  
▶ Supports DDR3 SDRAM integrated on FPGA board.  

RV64의 구현은 ALU와 ALUController, Instruction Decoder의 modding으로 구현하기로 했다. 
나머지 변경사항은 Data area와 Register File의 데이터 폭을 64비트로(XLEN)해야한다는 점. 
Instruction area는 RV64로 간다고 해도 instruction의 데이터는 32비트 폭 그대로라 변경사항은 없다. 
다만 Instruction area에서 주소로 가르킬 수 있는 범위가 64비트로 넓어졌으므로 데이터의 폭은 같되 깊이는 더 깊어진다. 
Instruction Decoder의 변경사항은 다음과 같다. 
"W" 접미사가 붙은 shifting 명령어들은 word, 즉 32-bit 단위 (RV64로 와도 한 명령어의 길이는 32-bit, 즉 word는 32-bit 단위이다. )를 처리한다. 
기존 RV32I에서 포함되어있는 SLL, SRA 같은 "W"접미사가 붙지 않은 명령어는 XLEN 만큼, 즉 RV64에서는 64비트 만큼 다루기에 shamt(Shift amount)가 6비트로 확장된다. 
하지만 기존 RV32I와 똑같이 32비트를 다루는 "W"접미사가 붙은 명령어는 RV32I 처럼 32비트를 다뤄야하기에 rs2는 기존과 같은 5비트로 제한된다. 
RV64I로 넘어오면서 새로이 생기는 명령어이기에 64비트를 다루는 명령어로 착각할 수 있지만, (내가 그랬다) 기존 32비트 처리 명령어가 있어야 하니까 그걸 W로 두고, 나머지 XLEN기반 명령어들은 
64-bit로 확장됨에 따라 특성이 변이하는 것이다. 

### RV64로 오면서 변하는 사항은 다음과 같다. 

[R-Type]
SLL, SRL, SRA : 최대 64비트 쉬프팅. rs2의 비트 영역이 6비트로 늘어나고, funct7이 대신 6비트로 줄어든다. (이름값 못하는 funct7이 된다. )

[I-Type]
SLLI, SRLI, SRAI : 최대 64비트 쉬프팅. imm값의 25:20을 shamt로 잡고, 31:26이 funct7으로 들어온다. (6비트)
LW : Load-word. 데이터 폭이 64비트로 바뀌었으므로 32비트를 로드하는데 나머지 남은 상위 32비트를 sign-extension한다.

신규 명령어.
[R-Type]
ADDW, SUBW, SLLW, SRLW, SRAW : 32비트 처리 명령어들. 덧셈, 뺄셈, 비트쉬프팅. 
각각 32비트로 계산하며, 그 결과의 상위 32비트를 sign-extension하여 쓰기한다. 

[I-Type]
ADDIW, SLLIW, SRLIW, SRAIW : 32비트 처리 상수 명령어들. 덧셈, 비트쉬프팅.
ADDIW는 마찬가지로 32비트 계산 후 sign-extension하여 쓰기한다. shifting은 위 설명대로. 

LWU, LD : Load(적재) 명령어. 
LWU - Load Word Unsigned. 32비트 데이터의 상위 32비트를 zero-extension하고 로드한다. 
LD - Load Double word. 64비트 데이터를 로드한다. 

이상이다. 

### 하드웨어 변경사항을 정리하면 다음과 같다.

1. Instruction Cache, Memory (Instruction Area)의 주소 폭 64비트. 

2. Instrcution Decoder : rs2의 비트 6비트로 확장, 'w'명령어일 때는 그에 맞는 비트 영역을 슬라이싱하도록 설계.

3. imm gen : 64비트 Sign-extension. (상황에 따라 zero-extension. U-Type)

4. Register File : 레지스터 데이터 폭 및 RD1, RD2 출력 비트 64비트. 

5. CSR File : CSR_RD 64비트. 나머지 CSR 레지스터는 그 규격에 맞게 32비트와 64비트를 병행. (설계 자체로서 데이터 폭은 64비트. 32비트 데이터 출력시 zero-extension)

6. ALU Controller : W명령어 (RV64-only instructions)전용 연산 ALUop코드 추가. (32비트 계산 후 64비트 확장)

7. ALU : ALUop코드에 따른 W명령어 연산 및 처리 추가

8. Data Cache, Memory (Data Area)의 주소 및 데이터 폭

기존에 basic_RV32s에 있던 RV64I 다이어그램도 추가했다. 
문서화해둔 basic_RV32s 아카이빙 자료 architecture specifications도 추가했다.

## [2025.12.23.]
RV32I와 RV64IMA 까지의 Cheatsheet를 모두 작성했다. 
이제는 RV64I의 확장이 본격적으로 시작되는데, 생각보다 수정할 부분이 많이 보여서 문제다.
따로 Dirty파일을 레포지토리로 파서 탑 모듈에서 항시 테스팅을함과 동시에 각 모듈별 진행을 이 ima_make_rv64에서 해야겠다.

## [2025.12.25.]
이 전까지는 basic_RV32s에서 예상치 못한 Z값과 X값들을 발견하여 해결하고 왔다.
지금은 XLEN으로 파라미터화를 시키고 있는데, 몇가지 궁금증이 생긴다.
1. XLEN은 64로 데이터의 폭이 2배인데, CSR에서 나머지 mcycle, mcycleh가 64비트로 하나가 된다고 해도 marchid같은 기존 32비트 값은 어떻게 되는건지 궁금하다. 그냥 64비트 길이로 알아서 설정하면 되는건가?
2. Instruction Memory 즉 ROM에는 32-bit 폭의 명령어들만 있는데, 이게 ROM_ADDRESS로 인식돼서 값을 불러올 때 32-bit값이 가야하나?
아니면 zero-extension인가? zero가 맞는 것 같긴한데.

파라미터화를 모두 마쳤고, PC와 Instruction Memory부터 64-bit testbench를 시작해보았다.
결과는 모두 잘 나오고, 값이 없는 63:32는 0으로 나와 괜찮은 것 같다. 이를 Instruction Decoder에서 31:0 까지만 받아들이고,
나머지 출력값은 그대로 64비트 유지를하면 나중에 ROM 영역 접근시 64-bit를 내보내야할 때 내보내지고, 명령어는 그대로 32-bit 규약에 맞춰진다.

## [2026.01.02.]
오랜만에 적는 devlog.
현재 봉착한 문제. Data Memory는 어떻게 수정되어야하는가.
명령어는 S-Type Store 명령어 4개와
I-Type Load 명령어 7개를 처리할 수 있어야 한다.

- S-Type
    - Store Byte
    - Store Halfword
    - Store Word
    - Store Doubleword

- I-Type (Load)
    - Load Byte
    - Load Byte Unsigned
    - Load Halfword
    - Load Halfword Unsigned
    - Load Word
    - Load Word Unsigned
    - Load Doubleword

이는 조금 다행이다. 실제로 다른 R-Type이나 I-Type들의 RV64I 확장시에는 기존 명령어가 64비트가 되고 32-bit 명령어가 별도로 W suffix가 붙었는데,
그대로 32-bit를 가져가되 새로운 64-bit 명령어가 생긴 것이다. 

추가로 구현해야하는 것은 그럼 기존에 있던 Store Word, Load Word 까지는 그대로 사용하고, 
Store Doubleword와 Load Word Unsigned, Load Doubleword를 구현해야한다.
물론 나머지 출력값들도 sign-extension하여 내보내는데 이에 Load Word와 Store Word를 추가하면 될 것이다. 