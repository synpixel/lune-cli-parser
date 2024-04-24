local Subcommand = require("./subcommand")

local function findSubcommandByName(subcommands: { Subcommand.Subcommand }, name: string): Subcommand.Subcommand?
	for _, subcommand in subcommands do
		if subcommand._name == name then
			return subcommand
		end
	end

	for _, subcommand in subcommands do
		local nestedSubcommand = findSubcommandByName(subcommand._subcommands, name)
		if nestedSubcommand then
			return nestedSubcommand
		end
	end

	return nil
end

local function parseSubcommand(
	rawArgs: { string },
	command: { _subcommands: { Subcommand.Subcommand } }
): (Subcommand.Subcommand?, number)
	local subcommand: Subcommand.Subcommand?

	local cursor = 1

	while true do
		local arg = rawArgs[cursor]
		if not arg then
			break
		end

		local argSubcommand = findSubcommandByName(command._subcommands, arg)
		if not argSubcommand then
			break
		end

		subcommand = argSubcommand

		cursor += 1
	end

	return subcommand, cursor
end

return parseSubcommand
