(*
	This file contains procedures that extract menu,
	item and subitem numbers from the code returned by
	Intuition. This works with V1.1
	See Intuition Manual V1.1 pages 6-9..6-12
	
	Created: 5/25/86 by Richie Bielak
	
	Modified:

	Copyright (c) 1986 by Richard Bielak
	
	This program may be freely copied, but please
	leave my name in. Thanks.....Richie

*)
IMPLEMENTATION MODULE DecodeMenu;

TYPE
  ShortSet = SET OF [0..15];

(* ++++++++++++++++++++++++++++ *)
(* Extract menu number          *)
PROCEDURE MenuNumber (code : CARDINAL) : CARDINAL;
  BEGIN
    (* Zero out everything, but the lower 5 bits *)
    RETURN CARDINAL (ShortSet (code) * ShortSet (01FH))
  END MenuNumber;

(* ++++++++++++++++++++++++++++ *)
(* Extract item number.         *)
PROCEDURE ItemNumber (code : CARDINAL) : CARDINAL;
  BEGIN
    (* Shift right by 5 positions *)
    code := code DIV 20H;
    (* Zero out, all but lower 6 bits *)
    RETURN CARDINAL (ShortSet (code) * ShortSet (03FH));
  END ItemNumber;

(*+++++++++++++++++++++++++*)
(* Extract Sub-item number *)
PROCEDURE SubItemNumber (code : CARDINAL) : CARDINAL;
  BEGIN
    (* Shift right by 11 bits *)
    code := code DIV 400H;
    (* Zero out all, but lower 5 bits *)
    RETURN CARDINAL (ShortSet (code) * ShortSet (01FH));
  END SubItemNumber;

END DecodeMenu.
