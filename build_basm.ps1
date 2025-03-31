param (
    [string]$arg0
)

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
odin build "src/basm" @commonFlags @debugFlags -out:"build/basm.exe" -build-mode:exe -debug -collection:comlib=comlib/ 

if ($lastExitCode -ne 0){ 
    Write-Output "Build failed"
    Exit
}

if ($arg0 -eq "run") {
    .\build\basm.exe -f .\test_files\test.asm -o test.o -d 
}
