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

odin build "src/" @commonFlags @debugFlags -out:"build/asm.exe" -build-mode:exe -debug 
