#Requires AutoHotkey >=2.0
#Include %A_LineFile%\..\JSON.ahk

json_str := "(
{
	""str"": ""Hello World"",
	""num"": 12345,
	""float"": 123.5,
	""true"": true,
	""false"": false,
	""null"": null,
	""array"": [
		""Auto"",
		""Hot"",
		""key""
	],
	""object"": {
		""A"": ""Auto"",
		""H"": ""Hot"",
		""K"": ""key""
	}
}
)"

parsed := JSON.parse(json_str, true)

parsed_out := Format("
(
String: {}
Number: {}
Float:  {}
true:   {}
false:  {}
null:   {}
array:  [{}, {}, {}]
object: {{A:""{}"", H:""{}"", K:""{}""}}
)"
, parsed.str, parsed.num, parsed.float, parsed.true, parsed.false, parsed.null
, parsed.array[1], parsed.array[2], parsed.array[3]
, parsed.object.A, parsed.object.H, parsed.object.K)

stringified := JSON.stringify(parsed, 4)

FileAppend("[PARSED]`n" parsed_out "`n`n[STRINGIFIED]`n" stringified "`n", "*")
ExitApp
