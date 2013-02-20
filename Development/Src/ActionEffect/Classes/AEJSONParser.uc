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
	return parseToMainChategories( parse( in ) );
}

/** Parse the string from server into a 2D array containing the main brackets. */
function array<Array2D> parse(string in)
{
	local array<Array2D>    parsed2DArray;
	local Array2D           parsedArray;
	local array<string>     mainBrackets;
	local array<string>     parsed;
	local string            bracket;

	if( Chr( Asc( in ) ) == "[" )
		in = mid( in, 1, len(in) - 1 );

	nextBracket = 0;

	mainBrackets = SplitFirstToEndBracket( in );

	if(mainBrackets.Length == 0)
		`log("[JSON] NOTHING TO PARSE");

	foreach mainBrackets( bracket )
	{
		parsed.Length = 0;
		parsed = splitToSections( bracket );
		parsedArray = parseToValues( parsed );
		parsed2DArray.AddItem( parsedArray );
	}

	return parsed2DArray;
}

/** Parses array to values */
function Array2D parseToValues(array<string> in)
{
	local array<string>     values;
	local Array2D           values2D;
	local string            stringValues;
	local string            valueString;
	
	foreach in( stringValues ){
		values = splitToVariables( stringValues );

		foreach values( valueString ){
			values2D.variables.addItem( splitToValue( valueString ) );
		}
	}

	return values2D;
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
  *	Returns the main brackets for the string */
function array<string> SplitFirstToEndBracket(string in)
{
	local array<string>     splitted;
	local string            temp;

	local bool          moreBrackets;
	local int           firstBracket;
	local int	        start;
	local int	        end;
	local int	        endBracket;
	local int           bracketCounter;

	bracketPositions.Length = 0;

	firstBracket = InStr( in, "{",,, firstBracket );
	endBracket = InStr( in, "}",,, firstBracket );
	start = 0;
	moreBrackets = true;

	while( moreBrackets )
	{
		if( endBracket > firstBracket ){
			firstBracket = InStr( in, "{",,, ++firstBracket );
			if(firstBracket == -1){
				end = InStr( in, "}", true );
				bracketCounter = 0;
			}else
				++bracketCounter;
		}else{
			--bracketCounter;
			endBracket = inStr( in, "}",,, endBracket + 1 );
			if(bracketCounter <= 0)
				end = inStr( in, "}", true,, firstBracket );
		}

		if(bracketCounter <= 0)
		{
			if(start == 0)
				temp = mid( in, start, end );
			else 
				temp = mid( in, start, end - start );
			start = InStr( in, "{",,, end );

			splitted.AddItem(temp);

			if( start == -1 ){
				moreBrackets = false;
				break;
			}
		}
	}

	return splitted;
}

/** Splits the string into its sections. */ 
function array<string> splitToSections(string in)
{
	local array<string> parsedtemp;
	local array<string> parsed;
	local int startBracket;
	local int endBracket;
	local int i;

	while( InStr( in, "{" ) != -1 )
	{
		startBracket = InStr( in, "{", true );

		endBracket = InStr( in, "}",,, startBracket );

		parsedtemp.AddItem( removeExcessChar( mid( in, startBracket, endBracket - startBracket ) ) );

		in = mid( in, 0, startBracket ) $ mid( in, endBracket + 1, len(in) );

		if(endBracket == -1)
			break;
	}

	for(i = parsedtemp.Length - 1; i >= 0 ; i--)
	{
		parsed.AddItem( parsedtemp[i] );
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
function ValueStruct splitToValue(string in)
{
	local array<string> splitted;
	local ValueStruct   value;

	splitted = SplitString( in, ":" );

	if( len( splitted[0] ) <= 1 )
		`log("[JSON] Empty occupant in splitToValue: " $ splitted[0]);
	if( splitted.Length > 2 )
		`log("[JSON] To many values when splitted in SplitToValue: " $ splitted.Length $ ": " $ splitted[0] $ " . " $ splitted[1] $ " . " $ splitted[2] );

	value.type = mid( splitted[0], 1, len( splitted[0] ) - 2 );

	if( float( splitted[1] ) == 0.0000f)
	{
		if( len( splitted[1] ) > 1 )
			value.value = mid( splitted[1], 1, len( splitted[1] ) - 2 );
	}else{
		value.value = splitted[1];
	}

	return value;
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
