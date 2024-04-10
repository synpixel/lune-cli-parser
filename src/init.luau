local process = require("@lune/process")
local stdio = require("@lune/stdio")
local Arg = require("arg")
local Subcommand = require("subcommand")
local parseArguments = require("parseArguments")
local help = require("help")

local Parser = {}
Parser.Arg = Arg
Parser.Subcommand = Subcommand

local function about(self: Parser, about: string): Parser
	self._about = about
	return self
end

local function arg(self: Parser, arg: Arg.Arg): Parser
	table.insert(self._args, arg)
	return self
end

local function subcommand(self: Parser, subcommand: Subcommand.Subcommand): Parser
	table.insert(self._subcommands, subcommand)
	subcommand._args[math.huge] = help.flag
	subcommand._parent = self
	return self
end

local function parse(self: Parser, rawArgs: { string }): { [string]: unknown, command: Subcommand.Subcommand? }
	local result = parseArguments(rawArgs, self)

	if result.help then
		stdio.write(help.buildHelpMessage(result.command or self))
		process.exit(0)
	end

	return result
end

function Parser.new(name: string)
	return {
		_name = name,
		_about = (nil :: any) :: string,
		_args = { [math.huge] = help.flag } :: { Arg.Arg },
		_subcommands = {} :: { Subcommand.Subcommand },

		about = about,
		arg = arg,
		subcommand = subcommand,
		parse = parse,
	}
end

export type Parser = typeof(Parser.new(...))

return Parser
