local Arg = {}

local function about(self: Arg, about: string): Arg
	self._about = about
	return self
end

local function short(self: Arg, short: string): Arg
	self._short = short
	return self
end

local function long(self: Arg, long: string): Arg
	self._long = long
	return self
end

local function optional(self: Arg): Arg
	self._optional = true
	return self
end

local function default(self: Arg, default: any): Arg
	self._default = default
	return self
end

local function string(self: Arg)
	self._type = "string"
	return self
end

local function number(self: Arg)
	self._type = "number"
	return self
end

local function boolean(self: Arg)
	self._type = "boolean"
	return self
end

function Arg.new(name: string)
	return {
		_name = name,
		_about = (nil :: any) :: string,
		_short = (nil :: any) :: string,
		_long = (nil :: any) :: string,
		_optional = false,
		_default = nil :: any,
		_type = (nil :: any) :: string,

		about = about,
		short = short,
		long = long,
		optional = optional,
		default = default,
		string = string,
		number = number,
		boolean = boolean,
	}
end

export type Arg = typeof(Arg.new(...))

return Arg
