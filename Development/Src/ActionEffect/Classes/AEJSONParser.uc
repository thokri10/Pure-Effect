class AEJSONParser extends Object;

// Used to get a 2 dimensional array
struct Array2D
{
	var array<string> arr;
};

// Used to set where the brackets start to split brackets inside a string.
var array<int>      bracketPositions;
// Controlls where the next main cathegory start in the string.
var int             nextBracket;

// Parse the string from server into a 2D array.
function array<Array2D> parse(string in)
{
	local array<Array2D>    parsedArray;
	local array<string>     parsed;
	local Array2D           asd;
	local int               endBracket;

	if( Chr( Asc( in ) ) == "[" )
		in = mid( in, 1, len(in) - 1 );

	nextBracket = 0;

	endBracket = InStr( in, "}", true );

	while(endBracket != nextBracket)
	{
		endBracket = nextBracket;
		nextBracket = SplitFirstToEndBracket( in, nextBracket );

		if(endBracket == nextBracket){
			break;
		}

		parsed.Length = 0;
		parsed = splitToSections( in );
		asd.arr = parsed;

		parsedArray.AddItem( asd );
	}

	return parsedArray;
}

// Parses the array into a more readable and controllable variableArray
function array<Array2D> parseToVariables(array<Array2D> in)
{
	local array<string>     variables;
	local array<string>     value;
	local array<Array2D>    returnArray;

	local Array2D           target;
	local Array2D           valueArray;
	local string            valueString;

	local string            targetString; 
	local string            targetVariable;

	foreach in(target)
	{
		foreach target.arr(targetString)
		{
			variables = splitToVariables( targetString );
			
			foreach variables( targetVariable )
			{
				value = splitToValue( targetVariable );
				valueString = value[0] $ ":" $ value[1];
				valueArray.arr.AddItem( valueString );
			}
			returnArray.AddItem( valueArray );
			valueArray.arr.Length = 0;
		}
	}

	return returnArray;
}

// Splits a string until it reaches the endbracket for the first bracket.
// Its used for splitting the missions into its own strings.
// Returns where the next main bracket start.
function int SplitFirstToEndBracket(string in, int firstBracket)
{
	local int endBracket;

	bracketPositions.Length = 0;
	while( InStr( in, "{",,, firstBracket ) != -1 )
	{
		endBracket = inStr( in, "}",,, firstBracket );
		firstBracket = InStr( in, "{",,, firstBracket );

		if( endBracket < firstBracket )
			break;

		bracketPositions.AddItem(++firstBracket);
	}

	return firstBracket;
}

// Splits the string into its sections. 
function array<string> splitToSections(string in)
{
	local array<string> parsed;
	local string temp;
	local int startBracket;
	local int i;

	startBracket = 0;
	for( i = (bracketPositions.Length - 1); i >= 0; --i )
	{
		startBracket = InStr( in, "}",,, bracketPositions[i] );
		
		// Takes out the section we want.
		temp = mid( in, bracketPositions[i], (startBracket - bracketPositions[i]) );
		temp = removeExcessChar( temp );

		parsed.InsertItem(i, temp);

		// Removes the text we just took out of the string.
		in = mid( in, 0, bracketPositions[i] ) $ mid( in, startBracket + 1, len( in ) );
	}

	return parsed;
}

// Splits the string with ",". 
// Returns an array that contains all the variables type and value in a string.
function array<string> splitToVariables(string in)
{
	local array<string> splitted;

	splitted = SplitString( in, "," );

	return splitted;
}

// Splits the string to readable valaues that can later be put into correct structs.
function array<string> splitToValue(string in)
{
	local array<string> splitted;

	splitted = SplitString( in, ":" );

	if( len( splitted[0] ) <= 1 )
		`log("[JSON] Empty occupant in splitToValue: " $ splitted[0]);
	if( splitted.Length > 2 )
		`log("[JSON] To many values when splitted in SplitToValue: " $ splitted.Length);

	splitted[0] = mid( splitted[0], 1, len( splitted[0] ) - 2 );

	if( float( splitted[1] ) == 0.0000f)
	{
		if( len( splitted[1] ) > 1 )
			splitted[1] = mid( splitted[1], 1, len( splitted[1] ) - 2 );
	}

	return splitted;
}

// Removes the "{}[]" characters in a string.  
function string removeExcessChar(string in)
{
	in = Repl(in, "}", "", false);
	in = Repl(in, "{", "", false);
	in = Repl(in, "[", "", false);
	in = Repl(in, "]", "", false);

	return in;
}

DefaultProperties
{
}
