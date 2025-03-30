if (-not (Test-Path -Path "build") ) { 
    mkdir "build"
}

$commonFlags = @(
    '-warnings-as-errors',
    '-show-timings',
    '-strict-style'
    '-vet'
)

$debugFlags = @( 
    '-o:none'
)

odin build "src/basm" @commonFlags @debugFlags -out:"build/basm.exe" -build-mode:exe -debug 
