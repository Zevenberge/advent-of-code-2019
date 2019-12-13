spawn "./intcode"

set score 0
set ball 0
set paddle 0

while { true } {
    expect -timeout 1 {
        -re "(.*)\n" {
            set x $expect_out(1,string)
            expect -re "(.*)\n"
            set y $expect_out(1,string)
            expect -re "(.*)\n"
            set val $expect_out(1,string)
        }
        timeout {
            puts score
            
        }
    }
}