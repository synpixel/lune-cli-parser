local Parser = require("../../src")
local greet = require("greet")

local parser = Parser.new("demo")
	:about("A simple to use, efficient, and full-featured Command Line Argument Parser")
	:subcommand(greet.command)

local function cli(rawArgs: { string })
	local args = parser:parse(rawArgs)
	if args.command == greet.command then
		greet.handle((args :: any) :: greet.GreetArgs)
	end
end

return cli
