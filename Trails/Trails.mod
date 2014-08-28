(*$T- Who needs range checking !!! *)
(*$S- Don't check the stack...     *)
MODULE Trails;

(* Just another cute demo of Amiga graphics and menus, etc.

   Created: 5/22/86 by Richard Bielak
   
   Modified:

	Copyright (c) 1986 by Richard Bielak
	
	This program can be freely copied, but please
	leave my name in. Thanks, Richie.

*)
FROM SYSTEM    IMPORT ADR, BYTE, ADDRESS, SETREG;
FROM Intuition IMPORT IntuitionName, IntuitionBase, WindowPtr, ScreenPtr,
                      IntuiMessagePtr, IDCMPFlags, IDCMPFlagsSet;
FROM GraphicsLibrary IMPORT GraphicsName, GraphicsBase, Jam2, Jam1, 
     Complement, DrawingModeSet;
FROM Pens 	IMPORT Draw, Move, SetAPen, SetDrMd, RectFill;
FROM Libraries  IMPORT OpenLibrary;
IMPORT Windows;
FROM Terminal   IMPORT WriteString, WriteLn;
FROM Ports      IMPORT WaitPort, ReplyMsg, MessagePtr;
FROM Fixes      IMPORT GetMsg;
FROM InputEvents IMPORT LButton, UpPrefix;
FROM Screens    IMPORT CloseScreen, ShowTitle;

(* The modules below are home grown *)
FROM TrailsMenu IMPORT ConnectMenu, DisconnectMenu, TrailsMenuType,
                       ActionItemType, SymetryItemType, SizeItemType,
		       SquareSizeItemType;
FROM TrailsScreen IMPORT SetUpScreen;
FROM TrailsInfo IMPORT ShowTrailsInfo, InitTrailsInfo;
FROM DecodeMenu IMPORT MenuNull, MenuNumber, ItemNumber;

CONST
  IntuitionRev = 29;
  MaxTrailLength = 128;

TYPE
  point = RECORD
            x, y : INTEGER;
          END;
VAR
  NULL : ADDRESS;
  wp : WindowPtr;
  sp : ScreenPtr;

  (* These variables hold the state of things *)
  ButtonDown : BOOLEAN;	        (* TRUE if the mouse button is down *)
  SizeOfTrail : INTEGER;        (* Size of trail, -1 if unlimited *)
  SizeOfSquare : INTEGER;       (* Size of the square we draw *)
  NumberOfSymetries : CARDINAL; (* Number of symetries *)
      
  (* This array is used for erasing of old trails *)
  OldTrails : ARRAY [0..MaxTrailLength-1] OF point;
  EndOfTrail: INTEGER;

(* ++++++++++++++++++++++++++++++++++ *)
PROCEDURE InitOldTrails ();
  VAR i : CARDINAL;
  BEGIN
    FOR i := 0 TO MaxTrailLength-1 DO 
      WITH OldTrails[i] DO x := -1; y := -1  END
    END;
  END InitOldTrails;

(* ++++++++++++++++++++++++++++++++++ *)
PROCEDURE OpenLibraries () : BOOLEAN;
  BEGIN
    (* Open intuition library *)
    IntuitionBase := OpenLibrary (IntuitionName,IntuitionRev);
    IF IntuitionBase = 0 THEN
      WriteString ("Open intuition failed"); WriteLn;
      RETURN FALSE
    END;
    (* Now open the graphics library *)
    GraphicsBase := OpenLibrary (GraphicsName, 0);
    IF GraphicsBase = 0 THEN 
      WriteString ("Open of graphics library failed "); WriteLn;
      RETURN FALSE 
    END;
    RETURN TRUE
  END OpenLibraries;

(* ++++++++++++++++++++++++++++++++++++ *)
PROCEDURE ProcessMenuRequest (code : CARDINAL; VAR quit : BOOLEAN);
  VAR
    menu, item : CARDINAL;

  (* +++++++++++++++++++++++++++++++ *)
  PROCEDURE ClearScreen (wp : WindowPtr);
    BEGIN
      WITH wp^ DO
        SetAPen (RPort^,0); SetDrMd (RPort^, Jam1);
	RectFill (RPort^, 0,0, 639, 199);
      END;
      InitOldTrails ()
    END ClearScreen;

  BEGIN
    menu := MenuNumber (code); item := ItemNumber (code);
    CASE TrailsMenuType (menu) OF
      Actions:
        CASE ActionItemType (item) OF
          HideTitle:   ShowTitle (sp^, FALSE);	  |
	  UnHideTitle: ShowTitle (sp^, TRUE);	  |
	  AboutTrails: ShowTrailsInfo (wp);	  |
	  ClearTrails: ClearScreen (wp);	  |
	  QuitTrails:  quit := TRUE
	END;
      |
      Symetry:
	CASE SymetryItemType (item) OF
	  OneFold:  NumberOfSymetries := 1;	|
	  TwoFold:  NumberOfSymetries := 2;	|
	  FourFold: NumberOfSymetries := 4;
	END;
      |
      Size:
        CASE SizeItemType (item) OF
          Size16:  SizeOfTrail := 16; |
          Size32:  SizeOfTrail := 32; |
          Size64:  SizeOfTrail := 64; |
          Size128:  SizeOfTrail := 128; |
	  Infinite: SizeOfTrail := -1
	END
      |
      SquareSize:
        CASE SquareSizeItemType (item) OF
	  Size2by2: SizeOfSquare := 2;    |
	  Size4by4: SizeOfSquare := 4;    |
	  Size8by8: SizeOfSquare := 8;    |
	  Size16by16: SizeOfSquare := 16; |
	  Size32by32: SizeOfSquare := 32; |
	END
    END;
  END ProcessMenuRequest;

(* ++++++++++++++++++++++++++++++++++++ *)
PROCEDURE ProcessButton (code : CARDINAL);
  BEGIN
    (* If the button was just pressed, make    *)
    (* Intuition report positions of the Mouse *)
    ButtonDown := code = LButton;
    Windows.ReportMouse (wp^, ButtonDown)
  END ProcessButton;

(* ++++++++++++++++++++++++++++++++++++ *)
PROCEDURE ProcessMouseMove (newX, newY : INTEGER);

  (* ++++++++++++++++++++++++++++++++++++ *)
  PROCEDURE DrawSquare (Xmin, Ymin : INTEGER);
    VAR Xmax, Ymax : INTEGER;
    BEGIN
      WITH wp^ DO
        (* Two pixels in the X direction are as *)
	(* wide as one pixel in the Y direction *)
	Xmax := Xmin + 2 * SizeOfSquare;
	IF Xmax > 640 THEN Xmax := 640; END;
	Ymax := Ymin + SizeOfSquare;
	IF Ymax > 200 THEN Ymax := 200; END;
        (* Note that Xmax >= Xmin and Ymax >= Ymin  *)
	(* otherwise we'll have a spectacular crash *)
	RectFill (RPort^, Xmin, Ymin, Xmax, Ymax);
      END
    END DrawSquare;

  (* ++++++++++++++++++++++++++++++++++++ *)
  PROCEDURE DrawTrail (X,Y : INTEGER; color : CARDINAL); 
    VAR x1, y1 : INTEGER;
    BEGIN
      (* Set color of the drawing pen, and set *)
      (* drawing mode to XOR.                  *)
      SetAPen (wp^.RPort^,color); 
      SetDrMd (wp^.RPort^, DrawingModeSet {Complement});
      (* Draw the symetric picture *)
      DrawSquare (X, Y);
      DrawSquare (640 - X, 200 - Y);
      IF NumberOfSymetries >= 2 THEN
        DrawSquare (X, 200 - Y);
        DrawSquare (640 - X, Y);
      END;
      IF NumberOfSymetries >= 4 THEN
        x1 := 16*(Y-100) DIV 5;
	y1 := 5*(X-320) DIV 16;
        DrawSquare ( x1 + 320, y1 + 100);
        DrawSquare (320 - x1, y1 + 100);
        DrawSquare (x1 + 320, 100 - y1);
        DrawSquare (320 - x1, 100 - y1);
      END
    END DrawTrail;

  BEGIN
    (* Do anything, only if the button is down *)
    IF ButtonDown THEN
      (* Finite trail *)
      IF SizeOfTrail > 0 THEN
        WITH OldTrails [EndOfTrail] DO
          (* First erase the end of the trails, if it's there *)
          IF x >= 0 THEN        
            DrawTrail (x, y, 0);
          END;
          (* Remmember new trails *)
	  x := newX; y := newY;	
	  DrawTrail (x, y, 1);
        END;
        (* Bump the trail counter *)
        INC (EndOfTrail);
	IF EndOfTrail >= SizeOfTrail THEN
          EndOfTrail := 0
	END
      (* Very long trail *)
      ELSE
   	DrawTrail (newX, newY, 1);
      END;
    END
  END ProcessMouseMove;

(* ++++++++++++++++++++++++++++++++++++ *)
PROCEDURE DoTrails ();
  VAR
    MsgPtr : IntuiMessagePtr;
    Quit   : BOOLEAN;
    code   : CARDINAL;
    class  : IDCMPFlagsSet;
    x, y   : CARDINAL;
  BEGIN
    Quit := FALSE;

    (* Initialize state variables *)
    ButtonDown := FALSE;
    SizeOfTrail := 64;
    SizeOfSquare := 4;;
    NumberOfSymetries := 2;
    EndOfTrail := 0;

    (* Get messages from intuition, and process them *)
    REPEAT
      (* Wait for a message *)
      MsgPtr := WaitPort (wp^.UserPort);
      (* Got something, process it *)
      REPEAT
        MsgPtr := GetMsg(wp^.UserPort);     
        IF MsgPtr <> NULL THEN
          class := MsgPtr^.Class; code := MsgPtr^.Code;
          x := MsgPtr^.MouseX; y := MsgPtr^.MouseY;
          ReplyMsg (MsgPtr);
          IF (class = IDCMPFlagsSet {MouseButtons}) THEN
	    ProcessButton (code)
          ELSIF (class = IDCMPFlagsSet {MouseMove}) THEN
            ProcessMouseMove (x,y);
          ELSIF (class = IDCMPFlagsSet {MenuPick}) AND (code <> MenuNull)
	    THEN
	    ProcessMenuRequest (code, Quit)
	  END;
	END; (* IF *)
      UNTIL MsgPtr = NULL
    UNTIL Quit
  END DoTrails;

VAR
  i : CARDINAL;
BEGIN
  (* Note "NIL" is not equal to ADDRESS (0) !!!! *)
  NULL := ADDRESS (0);
  InitOldTrails ();
  IF OpenLibraries () THEN  
    InitTrailsInfo ();
    SetUpScreen (wp, sp);
    (* Attach menu to the window *)
    ConnectMenu (wp);
    (* Don't report mouse until Button is clicked *)
    Windows.ReportMouse (wp^, FALSE);
    DoTrails ();
    DisconnectMenu (wp);
    (* Close the window and screen  *)
    Windows.CloseWindow (wp^);
    CloseScreen (sp^);
  END (* IF *)
END Trails.
