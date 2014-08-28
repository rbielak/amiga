(*
	This module initializes the window and screen for
	the trails program.
	
	Created: 5/24/86 by Richie Bielak
	
	Modified:

	Copyright (c) 1986 by Richard Bielak

	This program maybe freely copied. But please
	leave my name in. Thanks.....Richie

*)
IMPLEMENTATION MODULE TrailsScreen;

FROM SYSTEM    IMPORT ADR, BYTE, ADDRESS, SETREG;
FROM Intuition IMPORT
     WindowFlags, NewWindow, IDCMPFlags, IDCMPFlagsSet, WindowFlagsSet,
     WindowPtr, ScreenPtr;
FROM Windows   IMPORT OpenWindow, ReportMouse;
FROM Views     IMPORT Hires, ModeSet;
FROM Screens   IMPORT CustomScreen, OpenScreen, NewScreen;

VAR
  NULL : ADDRESS;
  MyWindow : NewWindow;
  MyScreen : NewScreen;
  ScreenName : ARRAY [0..20] OF CHAR;

(* +++++++++++++++++++++++++++++++++++++++ *)
PROCEDURE InitScreen (VAR s : NewScreen);
  BEGIN
    ScreenName := "Trails!";
    WITH s DO
      LeftEdge := 0; TopEdge := 0; 
      Width := 640; Height := 200;
      Depth := 2;
      DetailPen := BYTE (0); BlockPen := BYTE (1);
      ViewModes := CARDINAL (ModeSet {Hires});
      Type := CustomScreen;
      Font := NULL;
      DefaultTitle := ADR (ScreenName);
      Gadgets := NULL;
      CustomBitMap := NULL
    END;
  END InitScreen;

(* +++++++++++++++++++++++++++++++++++++++ *)
PROCEDURE InitWindow (VAR w : NewWindow; sp : ScreenPtr);
  BEGIN
    WITH w DO
      LeftEdge := 0; TopEdge := 0; Width := 640; Height := 200;
      DetailPen := BYTE (0);
      BlockPen := BYTE (1);
      Title := NULL;
      Flags := WindowFlagsSet {Activate, Borderless, BackDrop,
	                       ReportMouseFlag};
      IDCMPFlags := IDCMPFlagsSet{CloseWindow, MenuPick, ReqClear,
                        GadgetUp, GadgetDown, MouseButtons, MouseMove};

      Type := CARDINAL(CustomScreen);
      CheckMark := NULL;
      FirstGadget := NULL;
      Screen := sp;
      BitMap := NULL;
      MinWidth := 10; MinHeight := 10;
      MaxWidth := 640; MaxHeight := 200;
    END
  END InitWindow;
  
(* ++++++++++++++++++++++++++++++++++++++++ *)
PROCEDURE SetUpScreen (VAR wp : WindowPtr;
                       VAR sp : ScreenPtr);
  BEGIN
    InitScreen (MyScreen);
    (* Define a new screen *)
    sp := OpenScreen (MyScreen);
    InitWindow (MyWindow, sp);
    (* Now open the window *)
    wp := OpenWindow (MyWindow);
  END SetUpScreen;

BEGIN
  NULL := 0;
END TrailsScreen.
