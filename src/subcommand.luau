local Arg = require("./arg")

local Subcommand = {}

local function about(self: Subcommand, about: string): Subcommand
	self._about = about
	return self
end

local function arg(self: Subcommand, arg: Arg.Arg): Subcommand
	table.insert(self._args, arg)
	return self
end

local function subcommand(self: Subcommand, subcommand: Subcommand): Subcommand
	table.insert(self._subcommands, subcommand)
	subcommand._parent = self
	return self
end

local function isSubcommandOf(self: Subcommand, subcommand: Subcommand): boolean
	if self._parent == subcommand then
		return true
	end

	if self._parent then
		return isSubcommandOf(self._parent, subcommand)
	end

	return false
end

function Subcommand.new(name: string)
	return {
		_parent = nil :: any,
		_name = name,
		_about = (nil :: any) :: string,
		_args = {} :: { Arg.Arg },
		_subcommands = ({} :: any) :: { Subcommand },

		about = about,
		arg = arg,
		subcommand = subcommand,
		isSubcommandOf = isSubcommandOf,
	}
end

export type Subcommand = typeof(Subcommand.new(...))

return Subcommand
