#!/bin/bash

source venv/bin/activate
output=$(python -c "import pdal; r = pdal.Pipeline(); r |= pdal.Reader.las('PDAL/test/data/autzen/autzen-utm.las'); print(r.execute())")
if [ "$output" -eq 1065 ]; then
    echo "Test passed: Output is 1065"
else
    echo "Test failed: Output is $output"
    exit 1
fi
