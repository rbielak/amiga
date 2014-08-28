(*
	This module initializes the menus for the Trails
	demo.

	Created: 5/22/86 by Richard Bielak
	
	Modified:


	Copyright (c) 1986 by Richard Bielak.
	
	This is a Public Domain piece of code, please don't
	try to sell it! Also, please leave my name in.
	Thanks.....Richie.

*)
IMPLEMENTATION MODULE TrailsMenu;

FROM SYSTEM	IMPORT ADDRESS, ADR, BYTE;
FROM Intuition 	IMPORT WindowPtr, Menu, MenuPtr, IntuitionText,
	 	       IntuitionTextPtr, MenuItem, MenuItemPtr,
		       MenuFlags, MenuFlagsSet, ItemFlags, ItemFlagsSet;
FROM Menus	IMPORT SetMenuStrip, ClearMenuStrip, HighComp;
FROM GraphicsLibrary IMPORT Jam2, Jam1, DrawingModeSet;

CONST
  CheckWidth = 19; (* From Intuition.h *)

VAR
  NULL : ADDRESS;
  MenuStrip : MenuPtr;

  (*  ACTIONS   SYMETRY   SIZE  SQUARE*)
  Menus     : ARRAY [0..3] OF Menu;

  (* HideStrip, ShowStrip, About, Clear, Quit *)
  ActionItems : ARRAY [0..4] OF MenuItem;
  ActionText  : ARRAY [0..4] OF IntuitionText;

  (* 1 Fold, 2 Fold, 4 Fold *)
  SymetryItems : ARRAY [0..2] OF MenuItem;
  SymetryText  : ARRAY [0..2] OF IntuitionText;

  (* 16, 32, 64, 128, infinity *)
  SizeItems : ARRAY [0..4] OF MenuItem;
  SizeText  : ARRAY [0..4] OF IntuitionText;

  (* 2 by 2, 4 by 4, 8 by 8, 16 by 16, 32 by 32 *)
  SquareSizeItems : ARRAY [0..4] OF MenuItem;
  SquareSizeText  : ARRAY [0..4] OF IntuitionText;
  
(* ++++++++++++++++++++++++++++++++ *)
(* Connect a menu strip to a window *)
PROCEDURE ConnectMenu (wp : WindowPtr);
  BEGIN
    SetMenuStrip (wp^, MenuStrip^);
  END ConnectMenu;

(* +++++++++++++++++++++++++++++++++++++ *)
(* Disconnect a menu strip from a window *)
PROCEDURE DisconnectMenu (wp : WindowPtr);
  BEGIN
    ClearMenuStrip (wp^)
  END DisconnectMenu;

(* ++++++++++++++++++++++++++++++++ *)
(* Initialize a menu record.        *)
PROCEDURE InitMenuRec (VAR m : Menu; L, T, W, H : INTEGER;
                       VAR text : ARRAY OF CHAR) 
		       : MenuPtr;
  BEGIN
    WITH m DO
      NextMenu := NULL;
      LeftEdge := L; TopEdge := T;
      Width := W; Height := H;
      Flags := MenuFlagsSet {MenuEnabled};
      MenuName := ADR (text);
      FirstItem := NULL
    END;
    RETURN ADR (m)
  END InitMenuRec;

(* ++++++++++++++++++++++++++++++++ *)
(* Initialize an item record.       *)
PROCEDURE InitItemRec (VAR mi : MenuItem;
                       L, T, W, H : INTEGER;
		       ItemFillPtr : ADDRESS) 
		       : MenuItemPtr;
  BEGIN
    WITH mi DO
      NextItem := NULL;
      LeftEdge := L; TopEdge := T;
      Width := W; Height := H;
      Flags := ItemFlagsSet {ItemText, ItemEnabled} + HighComp;
      MutualExclude := 0;
      ItemFill := ItemFillPtr;
      SelectFill := NULL; Command := BYTE (0);
      SubItem := NULL; NextSelect := 0;
    END;
    RETURN ADR (mi)
  END InitItemRec;

(* ++++++++++++++++++++++++++++++++ *)
(* Initialize menu text record.     *)
PROCEDURE InitTextRec (VAR it : IntuitionText;
                       L, T : INTEGER;
		       VAR text : ARRAY OF CHAR) 
                       : IntuitionTextPtr;
  BEGIN
    WITH it DO
      FrontPen := BYTE(0); BackPen := BYTE(1);
      LeftEdge := L; TopEdge := T;
      DrawMode := BYTE (DrawingModeSet {Jam2});
      ITextFont := NULL;
      IText := ADR (text);
      NextText := NULL
    END;
    RETURN ADR (it);
  END InitTextRec;


VAR
  temp : ADDRESS;
  i    : CARDINAL;

BEGIN
  NULL := 0;
  MenuStrip := NULL;
  (* Now init menu records *)
  MenuStrip :=
   InitMenuRec (Menus[0], 10, 0, 112, 0, "Actions");
  Menus[0].NextMenu := 
    InitMenuRec (Menus[1], 10+112, 0, 80, 0, "Symetry");
  Menus[1].NextMenu := 
    InitMenuRec (Menus[2], 10+112+80, 0, 84, 0, "Length");
  Menus[2].NextMenu := 
    InitMenuRec (Menus[3], 10+112+80+84, 0, 100, 0, "Size");

  (* Define action items *)
  temp := InitTextRec (ActionText[0], 0, 0, "Hide Title Bar");
  Menus[0].FirstItem := 
    InitItemRec (ActionItems[0], 0, 0, 112, 9, temp);
  temp := InitTextRec (ActionText[1], 0, 0, "Show Title Bar");
  ActionItems[0].NextItem :=
    InitItemRec (ActionItems[1], 0, 10, 112, 9, temp);
  temp := InitTextRec (ActionText[2], 0, 0, "About Trails");
  ActionItems[1].NextItem :=
    InitItemRec (ActionItems[2], 0, 20, 112, 9, temp);
  temp := InitTextRec (ActionText[3], 0, 0, "Clear");
  ActionItems[2].NextItem :=
    InitItemRec (ActionItems[3], 0, 30, 112, 9, temp);
  temp := InitTextRec (ActionText[4], 0, 0, "Quit");
  ActionItems[3].NextItem :=
    InitItemRec (ActionItems[4], 0, 40, 112, 9, temp);

  (* Define Symetry Items *)
  temp := InitTextRec (SymetryText[0], 0+CheckWidth, 0, "1 Fold");
  Menus[1].FirstItem := 
    InitItemRec (SymetryItems[0], 0, 0, 80, 9, temp);
  INCL (SymetryItems[0].Flags,CheckIt);
  SymetryItems[0].MutualExclude := 0FEH;

  temp := InitTextRec (SymetryText[1], 0+CheckWidth, 0, "2 Fold");
  SymetryItems[0].NextItem := 
    InitItemRec (SymetryItems[1], 0, 10, 80, 9, temp);
  INCL (SymetryItems[1].Flags,CheckIt);
  INCL (SymetryItems[1].Flags,Checked);
  SymetryItems[1].MutualExclude := 0FDH;

  temp := InitTextRec (SymetryText[2], 0+CheckWidth, 0, "4 Fold");
  SymetryItems[1].NextItem := 
    InitItemRec (SymetryItems[2], 0, 20, 80, 9, temp);
  INCL (SymetryItems[2].Flags,CheckIt);
  SymetryItems[2].MutualExclude := 0FBH;

  (* Define Size items *)
  temp := InitTextRec (SizeText[0], 0+CheckWidth, 0, "16");
  Menus[2].FirstItem := 
    InitItemRec (SizeItems[0], 0, 0, 84, 9, temp);
  INCL (SizeItems[0].Flags,CheckIt);
  SizeItems[0].MutualExclude := 0FEH;
  
  temp := InitTextRec (SizeText[1], 0+CheckWidth, 0, "32");
  SizeItems[0].NextItem := 
    InitItemRec (SizeItems[1], 0, 10, 84, 9, temp);
  INCL (SizeItems[1].Flags,CheckIt);
  SizeItems[1].MutualExclude := 0FDH;

  temp := InitTextRec (SizeText[2], 0+CheckWidth, 0, "64");
  SizeItems[1].NextItem := 
    InitItemRec (SizeItems[2], 0, 20, 84, 9, temp);
  INCL (SizeItems[2].Flags,CheckIt);
  INCL (SizeItems[2].Flags,Checked);
  SizeItems[2].MutualExclude := 0FBH;

  temp := InitTextRec (SizeText[3], 0+CheckWidth, 0, "128");
  SizeItems[2].NextItem := 
    InitItemRec (SizeItems[3], 0, 30, 84, 9, temp);
  INCL (SizeItems[3].Flags,CheckIt);
  SizeItems[3].MutualExclude := 0F7H;

  temp := InitTextRec (SizeText[4], 0+CheckWidth, 0, "Infinite");
  SizeItems[3].NextItem := 
    InitItemRec (SizeItems[4], 0, 40, 84, 9, temp);
  INCL (SizeItems[4].Flags,CheckIt);
  SizeItems[4].MutualExclude := 0EFH;

  (* Size Square items *)
  temp := InitTextRec (SquareSizeText[0], 0+CheckWidth, 0, "2 by 2");
  Menus[3].FirstItem := 
    InitItemRec (SquareSizeItems[0], 0, 0, 100, 9, temp);
  INCL (SquareSizeItems[0].Flags,CheckIt);
  SquareSizeItems[0].MutualExclude := 0FEH;

  temp := InitTextRec (SquareSizeText[1], 0+CheckWidth, 0, "4 by 4");
  SquareSizeItems[0].NextItem := 
    InitItemRec (SquareSizeItems[1], 0, 10, 100, 9, temp);
  INCL (SquareSizeItems[1].Flags,CheckIt);
  INCL (SquareSizeItems[1].Flags,Checked);
  SquareSizeItems[1].MutualExclude := 0FDH;

  temp := InitTextRec (SquareSizeText[2], 0+CheckWidth, 0, "8 by 8");
  SquareSizeItems[1].NextItem := 
    InitItemRec (SquareSizeItems[2], 0, 20, 100, 9, temp);
  INCL (SquareSizeItems[2].Flags,CheckIt);
  SquareSizeItems[2].MutualExclude := 0FBH;

  temp := InitTextRec (SquareSizeText[3], 0+CheckWidth, 0, "16 by 16");
  SquareSizeItems[2].NextItem := 
    InitItemRec (SquareSizeItems[3], 0, 30, 100, 9, temp);
  INCL (SquareSizeItems[3].Flags,CheckIt);
  SquareSizeItems[3].MutualExclude := 0F7H;

  temp := InitTextRec (SquareSizeText[4], 0+CheckWidth, 0, "32 by 32");
  SquareSizeItems[3].NextItem := 
    InitItemRec (SquareSizeItems[4], 0, 40, 100, 9, temp);
  INCL (SquareSizeItems[4].Flags,CheckIt);
  SquareSizeItems[4].MutualExclude := 0EFH;

END TrailsMenu.

