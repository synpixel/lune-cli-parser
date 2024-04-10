local Parser = require("../../src")

export type GreetArgs = {
	name: string,
	formal: boolean,
	count: number,
}

local command = Parser.Subcommand
	.new("greet")
	:about("Greet somebody")
	:arg(Parser.Arg.new("name"):about("The name of the person you want to greet"):long("name"):string():default("John"))
	:arg(Parser.Arg.new("count"):about("The amount of times you want to greet them"):long("count"):number():default(1))
	:arg(Parser.Arg.new("formal"):about("Whether or not the greeting should be formal"):long("formal"):boolean())

local function handle(args: GreetArgs)
	for i = 1, args.count do
		if args.formal then
			print(`How are you doing on this fine day, {args.name}?`)
		else
			print(`hi {args.name}`)
		end
	end
end

return {
	command = command,
	handle = handle,
}
