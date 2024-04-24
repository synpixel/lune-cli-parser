local stdio = require("@lune/stdio")
local Arg = require("./arg")
local Subcommand = require("./subcommand")

local flag = Arg.new("help"):about("Print help"):long("help"):short("h"):boolean():optional()

local function findParser(command: { _parent: any })
	if not command._parent then
		return command
	end

	return findParser(command._parent)
end

local function traceCommandPath(command: { _parent: any, _name: string }, path: { string }): { string }
	path = path or {}

	table.insert(path :: { string }, command._name)

	if command._parent then
		return traceCommandPath(command._parent, path)
	end

	for i = 1, math.floor(#path / 2) do
		local j = #path - i + 1
		path[i], path[j] = path[j], path[i]
	end

	return path
end

local function bold(text: string)
	return stdio.style("bold") .. text .. stdio.style("reset")
end

local function buildHelpMessage(command: {
	_parent: any,
	_name: string,
	_about: string?,
	_args: { Arg.Arg },
	_subcommands: { Subcommand.Subcommand },
}): string
	local message = ""

	if command._about then
		message ..= command._about
		message ..= "\n\n"
	end

	local options = {}
	local longestOptionName = ""

	for _, arg in command._args do
		if not (arg._short or arg._long) then
			continue
		end

		local option = ""

		if arg._short then
			option ..= `-{arg._short}, `
		end

		if arg._long then
			option ..= `--{arg._long}`
		end

		if arg._type ~= "boolean" then
			option ..= ` <{arg._name:upper()}>`
		end

		if #option > #longestOptionName then
			longestOptionName = option
		end

		table.insert(options, {
			arg = arg,
			text = option,
		})
	end

	message ..= `{bold("Usage:")} {bold("lune.exe run")} {table.concat(traceCommandPath(command, {}), " ")}`

	if #options > 0 then
		message ..= " [OPTIONS]"
	end

	if #command._subcommands > 0 then
		message ..= " <COMMAND>"
	end

	for _, arg in command._args do
		if arg._optional or arg._type == "boolean" then
			continue
		end

		if arg._short or arg._long then
			if arg._type == "boolean" then
				message ..= ` --{arg._name}`
			else
				message ..= ` --{arg._name} <{arg._name:upper()}>`
			end
		else
			message ..= ` <{arg._name:upper()}>`
		end
	end

	if #command._subcommands > 0 then
		message ..= "\n\n"
		message ..= bold("Commands:")

		local longestCommandName = ""

		for _, command in command._subcommands do
			if #command._name > #longestCommandName then
				longestCommandName = command._name
			end
		end

		for _, command in command._subcommands do
			message ..= "\n  "
			message ..= `{bold(command._name)}{(" "):rep(#longestCommandName - #command._name) .. "  "}{command._about or ""}`
		end
	end

	if #options > 0 then
		message ..= "\n\n"
		message ..= bold("Options:")

		for _, option in options do
			message ..= "\n  "
			message ..= bold(option.text)

			if option.arg._about then
				message ..= `{(" "):rep(#longestOptionName - #option.text) .. "  "}{option.arg._about}`
			end

			if option.arg._default ~= nil then
				message ..= ` [default: {option.arg._default}]`
			end
		end
	end

	message ..= "\n\n"

	return message
end

return {
	flag = flag,
	buildHelpMessage = buildHelpMessage,
}
