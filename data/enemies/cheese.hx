import deltaflixel.objects.DeltaEnemy;
var enemy = new DeltaEnemy("Cheese", "characters/cheese", [
	{
		name: "idle",
		prefix: "queso",
		fps: 12,
		loop: true,
	},
	{
		name: "dead",
		prefix: "muerto",
		fps: 12,
		loop: true,
	},
], 4, 750, [
	"Kris" => [
		{
			text: "Check",
			func: () -> {
				events[eventName].push(() -> doTextStuff("* Cheese - 999 ATK - 999 DEF\nqueso bola queso hola", false, false, "default", null, 0.05));
			},
		},
	],
]);
script_return(enemy);