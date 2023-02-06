#!/bin/bash

mkdir -p CVE-cases

cat cmp-ret/eval-coreutils/coreutils.gcc94O0.vs.gcc94O3.pkl.dumped.csv|egrep "^single_binary_main_chown," > CVE-cases/case-18018.pem.csv
cat cmp-ret/eval-how-help/find47.locate.O0vsO3.pkl.dumped.csv|egrep "^visit_old_format," > CVE-cases/case-2452.pem.csv
cat cmp-ret/eval-trex/libmagick7.so.O0vsO3.pkl.dumped.csv|egrep "^sRGBTransformImage," > CVE-cases/case-20311.pem.csv
cat cmp-ret/eval-trex/libmagick7.so.O0vsO3.pkl.dumped.csv|egrep "^WaveImage," > CVE-cases/case-20309.pem.csv
cat cmp-ret/eval-trex/libmagick7.so.O0vsO3.pkl.dumped.csv|egrep "^ComplexImages," > CVE-cases/case-13308.pem.csv
cat cmp-ret/eval-trex/libz.so.O0vsO3.pkl.dumped.csv|egrep "^inflateMark," > CVE-cases/case-9842.pem.csv
cat cmp-ret/eval-trex/openssl101f.O0vsO3.pkl.dumped.csv|egrep "^X509_verify_cert," > CVE-cases/case-4044.pem.csv
cat cmp-ret/eval-trex/openssl101f.O0vsO3.pkl.dumped.csv|egrep "^EVP_PKEY_decrypt," > CVE-cases/case-3711.pem.csv
