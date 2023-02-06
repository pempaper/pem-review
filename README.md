# README

This repository contains the source code of PEM for review.
Due to time limits, we provide a brief document about the code.
A more detailed user guide will be added in the future. 
We will publish the source code upon publication of the paper.

In this file, we first introduce the structure of the repository.
Then, we illustrate the PEM's core components from the perspective of the code.

Additionally, we upload a runnable demo of PEM on Docker Hub.
Please refer to `README-docker.md` in this repository for more details.

## Introduction to the Repository

The repository is organized as follow:

```
├── README-docker.md
├── README.md
├── eval-scripts
├── eval-cross-arch
├── py-scripts
└── qemu-6.2.0
```

`README.md` is the file you are reading now.

`README-docker.md` contains the instructions for running PEM with a pre-configured Docker image.

`eval-scripts` and `eval-cross-arch` contains the scripts for running PEM on the evaluation dataset.

`py-scripts` contains the python scripts used by PEM.

`qemu-6.2.0` contains the source code of PEM. It is based on QEMU 6.2.0.


## Introduction to Core Components

We briefly go through the core components of PEM.
The step-by-step workflow of PEM is detailed in `README-docker.md`.
This file thus focuses on the probabilistic execution engine.

The probabilistic execution engine takes as input a binary file (and a set of static information, e.g., the CFG).
It iteratively samples each function in the binary file and stores the observable values in a file.
In this part, we mainly illustrate on three core parts of the engine:
(1) the interpreter, (2) the probabilistic path sampling algorithm, and (3) the probabilistic memory model.

### Interpretation Rules

The front-end of QEMU translates `x86` instructions into an intermediate representation(IR)
called `Tiny Code(TC)`.
The form of `TC` is similar to our illustrative language in Fig. 5.
They are defined in `qemu-6.2.0/linux-user/pr_emulator/inst.txt`.

The interpretation rules in Fig. 7 of the paper are defined in 
`qemu-6.2.0/linux-user/pr_emulator/emulator.hh`.
They are implemented in 
```
qemu-6.2.0/linux-user/pr_emulator/emulator.cc
qemu-6.2.0/linux-user/pr_emulator/emu_flow.cc
qemu-6.2.0/linux-user/pr_emulator/emu_value.cc
qemu-6.2.0/linux-user/pr_emulator/emu_libcall.cc
qemu-6.2.0/linux-user/pr_emulator/emu_operation.cc
```

The main function of the interpreter is defined at line 144 of `.../emulator.cc`.
It iteratively interpret each instruction inside a basic block (lines 167-204).
When the interpreter reaches the end of a basic block, it calls the function
`switchToNewBasicBlock` to decide the address of the next basic block.
Specifically, the statement at line 268 shows how the path sampling algorithm interacts with the interpreter.
```c
eip = sampler->guideBranch(currentEndPC - load_info.load_bias, EMU_PC - load_info.load_bias, ctx);
```
As shown in the rule `JccGT` of Fig. 7 of the paper,
the `sampler` use the program counter of current basic block (the first parameter)
to decide whether to flip the current branch or not.
If the branch is flipped, the `sampler` returns the address of the target basic block.
Otherwise, it returns the address of the original branch outcome (the second parameter).


### Probabilistic Path Sampling

PEM generates 20000 random numbers following a Beta distribution before the probabilistic execution.
At each step, PEM sorts all the predicates according to their dynamic selectivity.
Then it randomly picks a number from the pre-generated random numbers.
The number is further used to select the predicate to be flipped.

First, a list of random number is generated via `py-scripts/probabilistic_sampling.py`.
The script samples 20000 random numbers following a Beta distribution with parameter a=0.003.
Then the random numbers are normalized from $(0,1)$ to $[0,1]$.

During probabilistic execution, these random numbers are loaded into an array named `randomSamples`.
The main part of the path sampling algorithm is defined in
`qemu-6.2.0/linux-user/pr_sampler/selectivity_path_planner.cc`.
The probabilistic sampling is implemented from line 205 to line 209.

PEM first randomly select a sampled number.
```
auto randNum = rand();  
auto factor = randomSamples[(randNum % SAMPLE_SIZE)];
```
Since the sampled numbers in `randomSamples` follows a Beta distribution and `randNumber` is uniformly distributed, the number
`factor` follows a Beta distribution.


Then the index of the selected predicate is calculated by
```
auto selectedIdx = (int)(factor * (selectivityAllCandidates.size() - 1));
```

At lines 229-232, PEM selects the predicate to flip with the calculated index.
```
auto it = selectivityAllCandidates.begin();
for (auto i = 0; i < selectedIdx; i++) {
  it++;
}
```
Note that `selectivityAllCandidates` is an ordered set of predicates.
The traversal begins from the predicate with the smallest selectivity.

### Probabilistic Memory Model

Similar to the probabilistic path sampling algorithm, 
the initial values of the probabilistic memory model are
pre-generated by `py-scripts/generate_random_memory.py`.
It simply generates 4M random bytes and stores them in a file.

During probabilistic execution, the initial values are mapped to a memory region named `randomMem`.
The main part of the memory model is defined in
`qemu-6.2.0/linux-user/pr_emulator/emu_value.cc`.
The probabilistic memory model is implemented from line 79 to line 82.

```
auto page = new uint8_t[PAGE_SIZE];
...
auto probAddrBase = (addrBase & (PROB_MEM_SIZE - 1)) + randomMem;
memcpy(page, (const void *)probAddrBase, PAGE_SIZE);
```
Whenever an invalid memory access is detected,
PEM inserts a new page to the memory states maintained by PEM (`page`). 
The values are from the probabilisitc memory model (`probAddrBase`) .

