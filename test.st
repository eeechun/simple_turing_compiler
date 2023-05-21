var startOfProgram:=30
% this is single line comment

{%this
	is
	multi-line
	comment
%}

{%multi line comment test%}

% expression test
begin
const a := 1+1
const b := 1-1
const c := 1*1
const d := 1/1

const e := 1+1*1
const f := 1*1+1

const g := 1*-1
const h := -1*1
const i := --1

const j := -(1*1)
const k := -11mod 1

const l := true and true
const m := true or true
const n := not true

const o := not true and false
const p := not true or false
const q := true or not false
const r := true and not false

end

% constant declare test
begin
	const constInt := 3
	const constReal := 0.3
	const constBool := true
	const constString := "this is const ""string"""

	const constInt2 : int := 5
	const constReal2 : real := 0.5
	const constBool2 : bool := false
	const constString2 : string := """this is const String"""

	% expression
	constInt + constInt
	constInt - constInt
	constInt * constInt
	constInt / constInt
	

	const checkVal := constReal2 + constReal * constInt2

end

% variable declare test
begin
	% value declare
	var varInt := 3
	var varReal := 0.3
	var varBool := true
	var varString := "this is const ""string"""

	% type-value declare
	var varInt2 : int := 5
	var varReal2 : real := 0.5
	var varBool2 : bool := false
	var varString2 : string := """this is const String"""
	
	var varInt3 : int
	var varReal3 : real
	var varBool3 : bool
	var varString3 : string

	% assign and expression
	varInt := varInt + 1
	varReal := varReal + 1

	% type implicit conversion warning
		% int -> real
	varReal := varInt

		% real -> int
	varInt := varReal

		% bool -> real
	varReal := varBool

		% real -> bool
	varBool := varReal

		% bool -> int
	varInt := varBool
		
		% int -> bool
	varBool := varInt

	%  strange type conversion
	varString := varInt
end

% 1 dim array
begin
	% 1 dim array declare
	var arrInt: array 1..5 of int
	var arrReal: array 1..5 of real
	var arrBool: array 1..5 of bool

	% assign
	arrInt[1] := 1
	arrReal[1] := 0.1
	arrBool[1] := true
	
	% expression
	arrInt[1] := arrInt[2] + 1
	arrReal[1] := arrReal[2] + 0.1
	arrBool[1] := arrBool[2] or true
end

% function
begin
	function func(inFuncArg:int):int
		var insideFunc:= 3 + 1
		begin
			var insideFuncBlock:=3
		end
		result 33
	end func

	func(33)
end

%procedure
begin
	procedure proc(arg:int)
		var insideProc:= 3 + 1
		begin
			var insideProcBlock:=3
		end
		return
	end proc

	proc(33)
end

%if 
begin
	%if
	if (true and false) then
		var insideIf:=3
	end if

	%if-else
	if (true and false) then
		var insideIf:=3
	else
		var insideElse:=3
	end if
end

%for
begin
	%increase
	for i : 1..10
		var insideFor:=3
		exit when false
		exit
	end for
	
	%decrease
	for decreasing i : 1..10
		var insideDecreaseFor:=3
		exit when false
		exit
	end for
end

%loop
begin
	loop
		var insideLoop:=3

		exit when false
		exit
	end loop
end

var endOfProgram:=30
