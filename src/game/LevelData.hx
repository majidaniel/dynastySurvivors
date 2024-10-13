package game;

typedef EnemySpawn = {var type:EnemyType; var probability:Float;} 
typedef WaveData = {var waveType:WaveType; var enemyDistribution:Array<EnemySpawn>;}

typedef WaveSetup = {var waveType:WaveType; var startingThreat:Float;}
