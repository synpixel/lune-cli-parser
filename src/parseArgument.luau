local Result = require("result")
local Arg = require("arg")

local parsers: { [string]: (raw: string, arg: Arg.Arg) -> Result.Result<unknown, string> } = {
	string = function(raw)
		return Result.Ok(raw)
	end,

	number = function(raw, arg)
		local number = tonumber(raw)

		if not number then
			return Result.Err(`failed to parse "{arg._name}" to number`)
		end

		return Result.Ok(number)
	end,

	boolean = function(boolean)
		return Result.Ok(boolean)
	end,
}

local function parseArgument(raw: string, arg: Arg.Arg): Result.Result<unknown, string>
	if not parsers[arg._type] then
		return Result.Err(`failed to find type for argument "{arg._name}"`)
	end

	return parsers[arg._type](raw, arg)
end

return parseArgument
