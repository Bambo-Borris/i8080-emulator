if [ ! -d "build" ]; then
    mkdir -p "build"
fi

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

odin build "src/basm" "${commonFlags[@]}" "${debugFlags[@]}" -out:"build/basm" -build-mode:exe -debug -collection:comlib=comlib/
