importScript("data/scripts/DeltaCharacter");
importScript("data/scripts/eventSystem");
var enemy = createEnemy("Cheese", "characters/cheese", [
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
				addEventToList(() -> textEvent(dialogue, "* Cheese - 999 ATK - 999 DEF", false, scrollSound, 0.05));
				addEventToList(() -> {
					dialogue.text += "\n";
					textEvent(dialogue, "queso bola queso hola", true, scrollSound, 0.05);
				});
				addEventToList(() -> {
					conditionFunction = () -> {
						return controls.ACCEPT;
					};
				});
			},
		},
	],
]);
enemies.push(enemy);