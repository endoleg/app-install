start-transcript -path "C:\Users\$env:USERNAME\List-of-GPOs-and-Groups.log"

#list some Information like GPOs + group memberships
write-verbose -message "gpresult" -verbose
gpresult.exe /v

write-verbose -message "net user" -verbose
net user $env:USERNAME /domain 

stop-transcript
