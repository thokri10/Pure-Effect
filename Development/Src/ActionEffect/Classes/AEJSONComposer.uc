class AEJSONComposer extends Object
	dependson(AEJSONParser);

struct JSONCOMPOSER
{
	var ValueStruct value;
	var int stage;
};

var private string JSONSTRING_;

var private array<JSONCOMPOSER> values_;

function addVauleI(string type, int value, optional int stage = 0)
{
	addValueS(type, string(value), stage);
}

function addValueS(string type, string value, optional int stage = 0)
{
	local JSONCOMPOSER value_;
	value_.value.type = type;
	value_.value.value = value;
	value_.stage = stage;
	values_.AddItem(value_);
}

function string getString()
{
	return JSONSTRING_;
}

function string ComposeString()
{
	local string composedString;
	local JSONCOMPOSER value;
	local int currentStage;
	local int i;

	i = 0;
	composedString = "{";

	foreach values_(value)
	{
		while(currentStage < value.stage){
			composedString $= "{";
			++currentStage;
		}

		while(currentStage > value.stage){
			composedString $= "}";
			--currentStage;
		}

		// "Type":
		composedString $= "\"" $ value.value.type $ "\":";
		// "Value" || Value
		if(int(value.value.value) == 0)
			composedString $= "\"" $ value.value.value $ "\"";
		else
			composedString $= value.value.value;
		// Adds ',' if not the last value in bracket
		if(i != values_.Length - 1 && values_[i + 1].stage == currentStage)
			composedString $= ",";
		++i;
	}

	composedString $= "}";

	JSONSTRING_ = composedString;

	`log(composedString);

	return composedString;
}

DefaultProperties
{
}
