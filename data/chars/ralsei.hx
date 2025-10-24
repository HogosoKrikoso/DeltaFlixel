import deltaflixel.objects.DeltaCharacter;

var character = new DeltaCharacter("Ralsei", "ralsei", "characters/ralsei", [
	{
		name: "idle",
		prefix: "idle",
		fps: 12,
		loop: true,
	},
], 4, 140, 0xFF77FF00, true, [
	{
		text: "Heal Prayer",
		tp: 32,
		player: true,
		func: () -> {},
	},
], 0, 0);
characters.push(character);