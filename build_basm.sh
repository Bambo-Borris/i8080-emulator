if [ ! -d "build" ]; then
    mkdir -p "build"
fi

# Assign command-line arguments to variables
arg0="$1"
arg1="$2"
arg2="$3"

commonFlags=(
    "-warnings-as-errors"
    "-show-timings"
    "-strict-style"
    "-vet"
    "-use-separate-modules"
)

debugFlags=(
    "-o:none"
)

# Set the name of the game executable (omitting Windows-specific .exe)
exeName="build/basm"
if [ "$arg0" != "test" ]; then
    odin build "src/basm" "${commonFlags[@]}" "${debugFlags[@]}" -out:"build/basm" -build-mode:exe -debug -collection:comlib=comlib/
else
    odin test "src/basm/" -define:ODIN_TEST_FANCY=false -define:ODIN_TEST_SHORT_LOGS=true -out:"build/basm" -collection:comlib=comlib/ 
fi

if [ $? -ne 0 ]; then
    echo "Build command failed!"
    exit 1
else
    echo "Build succeeded"
fi

if [ "$arg1" == "run" ] || [ "$arg0" == "run" ]; then
    "$exeName" "-f" "./test_files/test.asm" "-o" "test.o" "-d"
    # "$exeName" "-f" "./test_files/test_2.asm" "-o" "test.o" "-d"
    # "$exeName" "-f" "./test_files/test_3.asm" "-o" "test.o" "-d"
fi
