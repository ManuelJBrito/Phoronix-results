#!/bin/bash -x 

# --------------------------------------------------------------------------------------------------------- #
# This script aims to pinpoint the perfdiff between different variants of GVN in a specific test.
# Assuming that all perf diff comes from optimizations performed in a single source file.
# This script runs the test multiple times where in each run 
# one file will be compiled using the bad_config and the others with the good_config.
#
# Usage:
#
#   ./run-diff.sh benchmark good_config bad_config src_dir
#
# Behavior:
#
#   export config_default = good_config
#   export config_nit = bad_config
#   
#   For each source file in profile:
#       export source_nit = source_file
#       # The following is the command to compile and run "profile"
#       # Assume that the compilation step understands what to do with "source_nit"
#       run.sh configs/config.json profile 
#   
# TODO: 
# 1. Assuming we can pinpoint the source file the next logical step is to pinpoint the IR level 
# function.
# 2. With the function in hand I can diff the IRs and discovered which specific transformation is 
# causing the perf diff.
# 3. Test the hypothesis by disabling the transformation and reruning the test. 
# 4. If it was incorrect go to step 2. Otherwise we need to decide if are going to further investigate 
# the perf diff 
# (by looking at things further down the pipeline) or if we just "fix it" call it a day and rerun the benchmarks.
#

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 benchmark good_config bad_config src_dir"
    exit 1
fi

benchmark=$1
good_config=$2
bad_config=$3
src_dir=$4

export config_nit=$bad_config
profile_files=$(find "$src_dir" -type f \( -name "*.c" -o -name "*.cpp" \) 2>/dev/null)

for source_file in $profile_files; do
    export source_nit=$source_file
    echo "Testing with $source_file compiled using bad_config..."
    ./run.sh configs/${good_config}.json $benchmark
    echo "Done testing with $source_file"
done



