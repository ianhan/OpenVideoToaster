/* Test sending commands to CG from FEP  */

options results
failat 30
addr=c2d(x2c(7777777))
call addlib(FEP.PORT,0)
say 'FEP_Begin()'  FEP_Begin(addr)
say 'FEP_Edit('addr','c2d(AL)')' FEP_Edit(addr,c2d(AL))
say 'FEP_VerifyFont("Ram:Times")' FEP_VerifyFont("Ram:Times")
say 'FEP_IntuiMsg(0x7777777)' FEP_IntuiMsg(addr)
say Exit(this,stuf)  /* This message will close the rexxhost */
call remlib(FEP.PORT)
exit

