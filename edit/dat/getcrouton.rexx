/* getcrouton.rexx */
/* TFOS AAR */

ProjectFcn = PROJECT_REXX_PORT

IF POS(ProjectFcn , SHOW('Libraries')) = 0 THEN
	IF ~ADDLIB(ProjectFcn , 0) THEN SAY 'Can not add Project function host'

say GetCrouton('Choose a crouton.')

exit
