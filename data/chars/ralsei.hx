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
		party: true,
		func: (charA, charB) -> {
			events[eventName].push(() -> doTextStuff("* Ralsei heals " + charB.name + ".", false, true, "default", null, 0.05));
			events[eventName].push(() -> {
				charA.playAnim("heal", true);
			});
		},
	},
], 0, 0);
characters.push(character);