importScript("data/scripts/DeltaCharacter");
var character = createCharacter("Ralsei", "ralsei", "characters/ralsei", [
	{
		name: "idle",
		prefix: "idle",
		fps: 12,
		loop: true,
	},
], 4, 140, 0xFF77FF00, true, [
	{
		text: "Heal Prayer",
		tp: 60,
		func: () -> {},
	},
], 0, 0);
characters.push(character);