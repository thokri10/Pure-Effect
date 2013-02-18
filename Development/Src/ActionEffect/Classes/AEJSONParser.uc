class AEJSONParser extends Object;


//-----------------------------------------------------------------------------
// Structs

/** Holds the value so we do not need to split the string the whole time. 
 *  Value can be a number but will be casted at a later time */
struct ValueStruct
{
	var string  type;
	var string  value;
};

// Used to get a 2 dimensional array
struct Array2D
{
	var array<string>       arr;
	var array<ValueStruct>  variables;
};


//-----------------------------------------------------------------------------
// Variables

// Used to set where the bracket start to split brackets inside a string.
var array<int>      bracketPositions;
// Controlls where the next section start in the string.
var int             nextBracket;

//-----------------------------------------------------------------------------
// Parsing

/** Parses the string to a 2D array variable list splitted with ":" */
function array<Array2D> fullParse(string in)
{
	return parseToMainChategories( parseToVariables( parse( in ) ) );
}

/** Parse the string from server into a 2D array containing the main brackets. */
function array<Array2D> parse(string in)
{
	local array<Array2D>    parsed2DArray;
	local Array2D           parsedArray;
	local array<string>     parsed;
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
		parsedArray.arr = parsed;

		parsed2DArray.AddItem( parsedArray );
	}

	return parsed2DArray;
}

/** Parses the array into a more readable and readable variableArray 
 *  Returns variables splitted with ":" */
function array<Array2D> parseToVariables(array<Array2D> in)
{
	local array<string>     variables;
	local array<string>     value;
	local array<Array2D>    returnArray;
	local ValueStruct       valueS;

	local Array2D           target;
	local Array2D           valueArray;

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
				valueS.type = value[0];
				valueS.value = value[1];
				valueArray.variables.AddItem( valueS );
			}
			returnArray.AddItem( valueArray );
			valueArray.variables.Length = 0;
		}
	}

	return returnArray;
}

/** Creates an array that contains an array with valuestruct * Type and Value */
function array<Array2D> parseToMainChategories(array<Array2D> in)
{
	local array<Array2D> parsed;
	local ValueStruct    value;
	local Array2D        temp;
	local Array2D        cathegory;
	local string         type;
	local int            index;

	index = 0;
	parsed.AddItem(temp);

	foreach in( cathegory )
	{
		foreach cathegory.variables( value )
		{
			if(type == "")
				type = value.type;
			else if( type == value.type ){
				++index;
				parsed.AddItem(temp);
			}

			parsed[index].variables.AddItem( value );
		}
	}

	return parsed;
}

/** Splits a string until it reaches the endbracket for the first bracket.
 Its used for splitting the types into its own strings.
 Returns where the next main bracket start. */
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

/** Splits the string into its sections. */ 
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

//-----------------------------------------------------------------------------
// Array splits and other

/** Splits the string with ",". 
*** Returns an array that contains all the variables type and value in a string. */
function array<string> splitToVariables(string in)
{
	local array<string> splitted;

	splitted = SplitString( in, "," );

	return splitted;
}

/** Splits the string to readable valaues that can later be put into correct structs. */
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

/** Splits the string where it finds ":" */
function array<string> splitValue(string in)
{
	local array<string> splitted;

	splitted = SplitString( in, ":" );
	
	return splitted;
}

/** Removes the "{}[]" characters in a string. */
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
