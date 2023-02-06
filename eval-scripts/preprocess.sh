#!/bin/bash -x

python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.gcc94.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.gcc94.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.gcc94.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.clang12.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.clang12.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-coreutils/coreutils.clang12.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/openssl101f.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libcurl460.so.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libsqlite3.so.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libmagick7.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/openssl101f.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libz.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/openssl101f.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libgmp620.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libz.so.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libcurl460.so.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libmagick7.so.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libz.so.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libgmp620.so.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libsqlite3.so.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libsqlite3.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libgmp620.so.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libmagick7.so.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-trex/libcurl460.so.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.cmp.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.sdiff.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff3.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.xargs.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.xargs.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.find.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.locate.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.sdiff.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.cmp.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.locate.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.locate.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.xargs.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff3.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.sdiff.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.cmp.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.find.O0.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff.O3.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/find47.find.O2.elf
python3 py-scripts/preprocess_large.py --src eval-dataset/eval-how-help/diff37.diff3.O3.elf
