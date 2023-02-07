# Overview

This file contains the instructions for running PEM and reproducing the results in the paper.
Reviewers will need to install Docker and pull the Docker image from [Docker Hub](https://hub.docker.com/r/pemauthors/pem-demo).
Then, they can run PEM in the Docker image.

The instruction consists of two parts:
The first part instructs reviewers pull the Docker image, build PEM,
and run a quick example.

The second part contains the instructions for running PEM on the whole evaluation dataset.

# Setup and Run a Quick Example
## Pull the Docker Image

Please use the following command to pull the Docker image.
The size of the image is about 3GB. It may take a few minutes to download the image.

```bash
docker pull pemauthors/pem-demo:first
```

After pulling the image, please run the container with the following command.
`-it` means the container is interactive.
`zsh` is the shell used in the container.
```bash
mkdir -p pem-shared-data
docker run -it pemauthors/pem-demo:first zsh
```

The PEM repository is located at `/root/pem-review` in the container.

## File Structure

After entering the directory `/root/pem-review`,
reviewers can see the following files and directories:
```
.
├── aarch64-coreutils
├── eval-cross-arch
├── eval-dataset
├── eval-scripts
├── py-scripts
└── qemu-6.2.0
```

The directory `qemu-6.2.0` contains the source code of PEM.
It is built on top of QEMU 6.2.0.
Please refer to our [GitHub repository](https://github.com/pempaper/pem-review) for detailed information about the source code.

The directory `py-scripts` contains the preprocess and postprocess scripts used in PEM.
It also contains the scripts for sampling random numbers used in the probabilistic path sampling algorithm 
and the probabilistic memory model.

The directory `eval-scripts` and `eval-cross-arch` contains the scripts for reproducing the results in the paper.

The directory `eval-dataset` and `aarch64-coreutils` contains the dataset used for evaluation.

## Build PEM

First, please make the following directories under `pem-review`
```
# Directories for building the x64 and aarch64 executable of PEM
mkdir -p pem-x64
mkdir -p pem-aarch64

# Directories for storing the intermediate comparison results between binary projects
mkdir -p cmp-ret
mkdir -p cmp-ret/eval-coreutils
mkdir -p cmp-ret/eval-trex
mkdir -p cmp-ret/eval-how-help

# Directories for storing the scores of comparison results (e.g., PR@1)
mkdir -p score-ret
mkdir -p score-ret/eval-coreutils
mkdir -p score-ret/eval-trex
mkdir -p score-ret/eval-how-help
```

Please run the following commands to build PEM. The build process may take around 15 minutes in total.
```
# Generate the protobuf files
cd py-scripts
./proto_gen.sh
cd ..
```

```
# Build the x64 executable of PEM
cd pem-x64
../qemu-6.2.0/configure --enable-tcg-interpreter --enable-debug --disable-pie --disable-system --enable-linux-user --target-list=x86_64-linux-user
make -j4
cd ..
```

```
# Build the aarch64 executable of PEM
cd pem-aarch64
../qemu-6.2.0/configure --enable-tcg-interpreter --enable-debug --disable-pie --disable-system --enable-linux-user --target-list=aarch64-linux-user
make -j4
cd ..
```

```
# Build the random numbers for the probabilistic path sampling algorithm
# and the probabilistic memory model
python3 py-scripts/probabilistic_sampling.py --a=3e-2 --fout pem-x64/prob_path.bin
python3 py-scripts/generate_random_memory.py pem-x64/mem.pmem 
cp pem-x64/prob_path.bin pem-aarch64/
cp pem-x64/mem.pmem pem-aarch64/
```


## A Quick Example

In this example, we use PEM to query functions in the `libcurl` binary program.
We will query with functions in the `libcurl` binary program compiled with `-O3`
in a pool of functions in the `libcurl` binary program compiled with `-O0`.

It consists of four steps:
1. The probabilistic execution engine first samples observable values for each function from both programs.
2. Then a preprocess script is used to aggregate the sampled values into multisets.
3. Set comparison is then performed on the multisets, calculating the similarity between every pair of functions.
The intermediate results are stored in the directory `cmp-ret/eval-trex/`.
5. Finally, a metric script is used to calculate the scores of the intermediate results.


**Step 1: Run the probabilistic execution engine on the two binary programs.**

It takes about 5 minutes to run the following commands.
```
pem-x64/qemu-x86_64 eval-dataset/eval-trex/libcurl460.so.O0.elf -M pem-x64/mem.pmem -P pem-x64/prob_path.bin
pem-x64/qemu-x86_64 eval-dataset/eval-trex/libcurl460.so.O3.elf -M pem-x64/mem.pmem -P pem-x64/prob_path.bin
```

After this step, the observable values are stored in `eval-dataset/eval-trex/eval-dataset/eval-trex/libcurl460.so.O0.elf*.pb` and `eval-dataset/eval-trex/libcurl460.so.O3.elf*.pb`.
The `*.pb` files are protobuf files whose format is defined in `py-scripts/sem_features.proto`.

**Step 2: Aggregate the sampled values into multisets.**
It takes about 5 minutes to run the following commands.
```
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libcurl460.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libcurl460.so.O3.elf
```
After this step, the multisets are stored in `eval-dataset/eval-trex/libcurl460.so.O0.elf.preprocess.pkl`
and `eval-dataset/eval-trex/libcurl460.so.O3.elf.preprocess.pkl`.
These two files are pickle files, which can be directly loaded by python.

**Step 3: Perform set comparison on the multisets.**
The following commands leverage 4 processes. It takes about 5 minutes.
```
python3 py-scripts/compare.py --src eval-dataset/eval-trex/libcurl460.so.O0.elf --tgt eval-dataset/eval-trex/libcurl460.so.O3.elf --fout cmp-ret/eval-trex/libcurl460.so.O0vsO3.pkl
```
The intermediate results are stored in `cmp-ret/eval-trex/libcurl460.so.O0vsO3.pkl`.

**Step 4: Calculate the scores of the intermediate results.**
It takes about 1 minute to run the following command.
```
python3 py-scripts/score.py --src eval-dataset/eval-trex/libcurl460.so.O0.elf --tgt eval-dataset/eval-trex/libcurl460.so.O3.elf --cmp cmp-ret/eval-trex/libcurl460.so.O0vsO3.pkl > score-ret/eval-trex/libcurl460.so.O0vsO3.score.txt 2>&1
```
The scores are stored in `score-ret/eval-trex/libcurl460.so.O0vsO3.score.txt`.

The score script takes an optional argument `--sample`. 
It specifies the number of negative samples (i.e., different function pairs)
to be used for each positive sample (i.e., the same function pair).

For example, the following command uses 100 negative samples for each positive sample.
```
python3 py-scripts/score.py --src eval-dataset/eval-trex/libcurl460.so.O0.elf --tgt eval-dataset/eval-trex/libcurl460.so.O3.elf --cmp cmp-ret/eval-trex/libcurl460.so.O0vsO3.pkl --sample 100 > score-ret/eval-trex/libcurl460.so.O0vsO3.score.100.txt 2>&1
```
The scores are stored in `score-ret/eval-trex/libcurl460.so.O0vsO3.score.100.txt`.


# Evaluation on the Full Dataset


We combine the above steps into a single script to simplify the evaluation process.
Please run the following commands to evaluate PEM on the full dataset.
It takes about 20 hours to finish.
Also, it requires about 190GB of disk space.
```
eval-scripts/run.sh
```

After the above script finishes, the scores are stored in `score-ret`.
All the scores are sampled in `1:100` by default.

Next, we will show how to reproduce the results in the paper.

## Table 1

The detailed instructions for reproducing the results in Table 1
are illustrated in our supplementary material submitted with the paper.
For convenience, we put all the commands in the following script.
It takes around 20 minutes to finish.
```
eval-scripts/eval-coreutils.sh
```

Then the reported scores can be seen with the following command.
```
eval-scripts/coreutils_report-score.sh 
```

## Comparison with ML-based Approaches

The scores stored in `score-ret` are used to compare PEM with ML-based approaches.
These scores are sampled in `1:100`, following the setting in the How-Solve paper.

Use the following command to see the scores.
```
find score-ret -name "*.txt"|xargs tail -n +1 |less
```

## Figure 26 in the Supplementary Material

By changing the parameters in the top of `eval-scripts/score.sh`  to different numbers,
we can reproduce the results used in Figure 26. 

## Case Study

The following commands generate the `.csv` files used in the case study.
It takes around 20 minutes to finish.
```
eval-scripts/eval-case.sh
```
The `.csv` files are stored in `CVE-cases/`.
Then we use Excel to sort the `.csv` files and manually inspect the results.

## Cross-architecture Evaluation

The following commands evaluate PEM on the cross-architecture dataset.
It takes around 2 hours to finish.
```
eval-cross-arch/run.sh
```
The scores are stored in `score-ret/cross-arch`.
The reported scores contain **all** possible negative samples in comparisons.

## Coverage

The coverage per function is stored in the `*.cov` files 
for each binary program. They are in the same path as the binary programs (in `eval-dataset` directory).

## Ablation Study

For ablation study, we manually change the code in `qemu-6.2.0/linux-user/pem_config.cc`
and recompile PEM to collect different sets of results.

