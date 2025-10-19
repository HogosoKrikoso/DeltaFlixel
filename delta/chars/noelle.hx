importScript("data/scripts/DeltaCharacter");
var character = createCharacter("Noelle", "Noelle", "characters/noelle", [
	{
		name: "idle",
		prefix: "idle",
		fps: 12,
		loop: true,
	},
], 4, 120, 0xFFFFFF00, true, [
	{
		text: "Queso",
		tp: 100,
		func: () -> {},
	},
], 0, 0);
characters.push(character);