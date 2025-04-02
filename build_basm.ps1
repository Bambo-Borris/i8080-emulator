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

if ($arg0 -ne "test") {
    odin build "src/basm" @commonFlags @debugFlags -out:"build/basm.exe" -build-mode:exe -debug -collection:comlib=comlib/
} else {
    odin test .\src\basm\ -define:ODIN_TEST_FANCY=false -define:ODIN_TEST_SHORT_LOGS=true -out:"build/basm.exe" -collection:comlib=comlib/ 
}

if ($lastExitCode -ne 0){ 
    Write-Output "Build failed"
    Exit
}

if ($arg0 -eq "run") {
    # .\build\basm.exe -f .\test_files\test.asm -o test.o -d 
    # .\build\basm.exe -f .\test_files\test_2.asm -o test.o -d 
    .\build\basm.exe -f .\test_files\test_3.asm -o test.o -d 
}
