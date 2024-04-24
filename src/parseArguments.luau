local Arg = require("./arg")
local Subcommand = require("./subcommand")
local parseArgument = require("./parseArgument")
local parseSubcommand = require("./parseSubcommand")
local Option = require("@pkg/option")

local function findArgFromName(args: { Arg.Arg }, name: string)
	for _, arg in args do
		if arg._name == name then
			return arg
		end
	end

	return
end

local function isBooleanFlag(rawArg: string, args: { Arg.Arg })
	for _, arg in args do
		if "--" .. arg._name == rawArg and arg._type == "boolean" then
			return true
		end
	end

	return false
end

local function parseArguments(
	rawArgs: { string },
	command: { _args: { Arg.Arg }, _subcommands: { Subcommand.Subcommand } }
)
	local positionals: { Option.Option<string> } = {}
	local flags: { [string]: Option.Option<string> } = {}
	local subcommand, cursor = parseSubcommand(rawArgs, command)

	local args = if subcommand then subcommand._args else command._args

	while true do
		local arg = rawArgs[cursor]

		if not arg then
			break
		end

		if isBooleanFlag(arg, args) then
			flags[arg:sub(3)] = Option.Some(true)
			cursor += 1
			continue
		end

		if arg:sub(1, 2) == "--" then
			flags[arg:sub(3)] = Option.Some(rawArgs[cursor + 1])
			cursor += 2
		else
			table.insert(positionals, Option.Some(arg))
			cursor += 1
		end
	end

	if flags.help then
		return {
			command = subcommand or command,
			help = true,
		}
	end

	for flag, _ in flags do
		if not findArgFromName(args, flag) then
			error(`failed to find flag "{flag}"`)
		end
	end

	local result: { [string]: unknown } = {}

	local positionalArgs = {}

	for _, arg in args do
		if not (arg._short or arg._long) then
			table.insert(positionalArgs, arg)
		end
	end

	for _, arg in args do
		local type: "flag" | "positional" = "flag"

		if not (arg._short or arg._long) then
			type = "positional"
		end

		if type == "positional" and (arg._optional or arg._default) then
			error("positional argument cannot be optional")
		end

		local rawArg: Option.Option<string> = Option.None

		if type == "flag" then
			rawArg = Option.from(flags[arg._long] or flags[arg._short]):unwrapOr(Option.None)
		else
			rawArg = positionals[table.find(positionalArgs, arg) :: number] or Option.None
		end

		if type == "flag" and rawArg:isNone() and arg._type == "boolean" then
			rawArg = Option.Some(false)
		end

		if rawArg:isNone() and arg._default ~= nil and not arg._optional then
			rawArg = Option.Some(arg._default)
		end

		if not (rawArg:isSome() or arg._optional) then
			error(`missing argument "{arg._name}"`)
		end

		if rawArg:isSome() then
			local parsed = parseArgument(rawArg:unwrap(), arg)

			if parsed:isErr() then
				error(parsed:unwrapErr())
			end

			result[arg._name] = parsed:unwrap()
		end
	end

	result.command = subcommand

	return result
end

return parseArguments
