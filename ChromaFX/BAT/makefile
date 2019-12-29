#********************************************************************
#* $RCSfile: makefile,v $
#*
#* Copyright (c)1992 NewTek, Inc.
#* Confidental and Proprietary. All rights reserved. 
#*
#* $Id: makefile,v 2.12 1994/10/04 20:28:12 pfrench Exp $
#*
#*********************************************************************
# HiSoft assembler include path
HISOFT = -icfx:inc/ -L -D LINE -O

#ASSEMBLE = GenIm2
ASSEMBLE = GenAm
ASSEMERRS = >cfx:hisoft.errs

LINK = slink
LINKERRS = >cfx:slink.errs

DEST = VT:exe/Toaster/AuxLibs/

OBJS = \
 cfx:obj/lut0.o \
 cfx:obj/lut1.o \
 cfx:obj/lut2.o \
 cfx:obj/lut3.o \
 cfx:obj/lut4.o \
 cfx:obj/lut5.o \
 cfx:obj/lut6.o \
 cfx:obj/lut7.o \
 cfx:obj/lut8.o \
 cfx:obj/lut9.o \
 cfx:obj/lutA.o \
 cfx:obj/lutB.o \
 cfx:obj/lutC.o \
 cfx:obj/LutBits.o \
 cfx:obj/LutRam.o \
 cfx:obj/LutLib.o

$(DEST)ChromaFX: $(OBJS)
	$(LINK) $(LINKERRS) WITH cfx:bat/withfile

###########################################################
# This line is to support testmake
ram:NeverExists: $(OBJS)
	quit 20

###########################################################
# NOTE: These Lut files don't have the correct dependencies!!!!!
DEPEND = cfx:inc/assembler.i cfx:inc/LUTequ.i tinc:InstinctUpdate tinc:EfLibUpdate

cfx:obj/lut0.o: cfx:src/lut0.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut0.a $(HISOFT)cfx:obj/lut0.o

cfx:obj/lut1.o: cfx:src/lut1.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut1.a $(HISOFT)cfx:obj/lut1.o

cfx:obj/lut2.o: cfx:src/lut2.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut2.a $(HISOFT)cfx:obj/lut2.o

cfx:obj/lut3.o: cfx:src/lut3.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut3.a $(HISOFT)cfx:obj/lut3.o

cfx:obj/lut4.o: cfx:src/lut4.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut4.a $(HISOFT)cfx:obj/lut4.o

cfx:obj/lut5.o: cfx:src/lut5.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut5.a $(HISOFT)cfx:obj/lut5.o

cfx:obj/lut6.o: cfx:src/lut6.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut6.a $(HISOFT)cfx:obj/lut6.o

cfx:obj/lut7.o: cfx:src/lut7.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut7.a $(HISOFT)cfx:obj/lut7.o

cfx:obj/lut8.o: cfx:src/lut8.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut8.a $(HISOFT)cfx:obj/lut8.o

cfx:obj/lut9.o: cfx:src/lut9.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lut9.a $(HISOFT)cfx:obj/lut9.o

cfx:obj/lutA.o: cfx:src/lutA.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lutA.a $(HISOFT)cfx:obj/lutA.o

cfx:obj/lutB.o: cfx:src/lutB.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lutB.a $(HISOFT)cfx:obj/lutB.o

cfx:obj/lutC.o: cfx:src/lutC.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/lutC.a $(HISOFT)cfx:obj/lutC.o

cfx:obj/LutBits.o: cfx:src/LutBits.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/LutBits.a $(HISOFT)cfx:obj/LutBits.o

cfx:obj/LutRam.o: cfx:src/LutRam.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/LutRam.a $(HISOFT)cfx:obj/LutRam.o

cfx:obj/LutLib.o: cfx:src/LutLib.a $(DEPEND)
	$(ASSEMBLE) $(ASSEMERRS) cfx:src/LutLib.a $(HISOFT)cfx:obj/LutLib.o

# end of makefile
