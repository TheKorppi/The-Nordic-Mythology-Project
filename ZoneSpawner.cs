using Godot;

public partial class ZoneSpawner : Node3D
{
	[Export] public Godot.Collections.Array<PackedScene> EnemyPool { get; set; } = new Godot.Collections.Array<PackedScene>();
	
	[Export] public int MinEnemies = 2;
	[Export] public int MaxEnemies = 4;
	[Export] public float SpawnRadius = 5.0f;

	// Tämä pitää huolen, että karhuja ei synny loputtomasti, jos pelaaja ravaa ees taas ovesta!
	private bool _hasSpawned = false;

	public override void _Ready()
	{
		// Etsitään spawnerin sisältä Area3D-node
		Area3D activationArea = GetNodeOrNull<Area3D>("ActivationArea");
		
		if (activationArea != null)
		{
			// Yhdistetään alueen signaali koodiin
			activationArea.BodyEntered += OnBodyEntered;
		}
		else
		{
			GD.PrintErr("ZoneSpawner tarvitsee ActivationArea-noden!");
		}
	}

	private void OnBodyEntered(Node3D body)
	{
		// Vain serveri saa luoda karhuja, ja ne luodaan vain kerran
		if (!Multiplayer.IsServer() || _hasSpawned) return;

		// Varmistetaan, että alueelle astunut asia on nimenomaan Pelaaja (eikä esim. toinen karhu tai luoti)
		if (body.IsInGroup("Player"))
		{
			_hasSpawned = true;
			SpawnEnemies();
		}
	}

	private void SpawnEnemies()
	{
		if (EnemyPool.Count == 0) return;

		Node enemiesContainer = GetTree().Root.GetNodeOrNull("Game/Enemies");
		if (enemiesContainer == null) return;

		RandomNumberGenerator rng = new RandomNumberGenerator();
		rng.Randomize();

		int enemyCount = rng.RandiRange(MinEnemies, MaxEnemies);

		for (int i = 0; i < enemyCount; i++)
		{
			PackedScene randomEnemy = EnemyPool[rng.RandiRange(0, EnemyPool.Count - 1)];
			Node3D enemyInstance = randomEnemy.Instantiate<Node3D>();

			float randomX = rng.RandfRange(-SpawnRadius, SpawnRadius);
			float randomZ = rng.RandfRange(-SpawnRadius, SpawnRadius);
			
			enemyInstance.Position = GlobalPosition + new Vector3(randomX, 0, randomZ);
			enemyInstance.Name = "Enemy_" + rng.Randi();
			enemiesContainer.AddChild(enemyInstance, true);	
		}
	}
}
