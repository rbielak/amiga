(*
	This module implements fixes to some of TDI's
	interface routines to ROM Kernel.

	Created: 4/9/86 by TDI

	Modified:

*)
IMPLEMENTATION MODULE Fixes;
 FROM SYSTEM IMPORT CODE, SETREG, REGISTER, ADDRESS;
 FROM Tasks IMPORT SignalSet;
 FROM Ports IMPORT MsgPortPtr, MessagePtr;

 CONST
   AbsExecBase = 4;
 VAR
   ExecBase [AbsExecBase]: ADDRESS;

 PROCEDURE GetMsg (port: MsgPortPtr): MessagePtr;
 BEGIN
   CODE (2F0EH);
   SETREG (8, port); SETREG (14, ExecBase);
   CODE (4EAEH, (-30-342), 2C5FH);
   RETURN MessagePtr (REGISTER (0));
 END GetMsg;

 PROCEDURE Wait (sig: SignalSet): SignalSet;
 BEGIN
   CODE (2F0EH);
   SETREG (0, sig); SETREG (14, ExecBase);
   CODE (4EAEH, (-30-288),2C5FH);
   RETURN SignalSet (REGISTER (0));
 END Wait;

END Fixes.
