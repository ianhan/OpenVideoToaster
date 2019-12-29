/* Send commands and function calls to RexxHost  */

parse arg port
options results
if port="" then exit
if pos(port,show('P'))=0 then do
  say "Can't find port "port
  exit
  end
cmd="ADDRESS "port
interpret cmd
call addlib(port,0)
call FEP_Begin(1000007)
call FEP_Edit(45000)
hum
"We're Commands,"
say snoop(doggy,'Doggy')
FEP_VerifyFont
FEP_Int
call quit(this,stuf)
"quit"
call remlib(port)
exit

