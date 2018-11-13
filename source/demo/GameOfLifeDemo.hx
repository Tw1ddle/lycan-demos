package demo;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

/**
 * Demo that implements Conway's Game of Life.
 * @see https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
 */
class GameOfLifeDemo extends BaseDemoState {
	/**
	 * The color of live cells.
	 */
	public static var liveCellColor:UInt = 0xFFFF0000;
	
	/**
	 * The color of dead cells.
	 */
	public static var deadCellColor:UInt = 0xFF0000FF;
	
	/**
	 * The color of the background.
	 */
	private static var worldBackgroundColor:UInt = 0xFFFFFFFF;
	
	/**
	 * The update timestep for the simulation.
	 */
	private var simulationTimestepSeconds:Float;
	
	/**
	 * Helper variable for keeping track of time elapsed between time steps.
	 */
	private var timestepCounter:Float;
	
	/**
	 * Whether the simulation is running or paused.
	 */
	private var simulationRunning:Bool;
	
	/**
	 * Fullscreen sprite that contains the state of the world for the current generation of the simulation.
	 */
	private var sprite:FlxSprite;
	
	/**
	 * Text showing the current generation number.
	 */
	private var generationText:FlxText;
	
	/**
	 * The current generation of the simulation.
	 */
	private var currentGeneration(default, set):UInt;
	
	/**
	 * Text showing the number of living cells.
	 */
	private var livingCellsText:FlxText;
	
	/**
	 * The set of live cells in the current generation of the simulation.
	 */
	private var livingCells:Array<Cell>;
	
	/**
	 * The events that will trigger changes to the cells for the next step of the simulation.
	 */
	private var cellChanges:Array<CellChange>;
	
	public function new() {
		super();
		
		simulationTimestepSeconds = 0.0; // Run as fast as Flixel updates
		timestepCounter = 0;
		simulationRunning = false;
		
		sprite = new FlxSprite(0, 0);
		sprite.makeGraphic(FlxG.width, FlxG.height, worldBackgroundColor);
		add(sprite);
		
		generationText = new FlxText(0, FlxG.height * 0.05);
		generationText.size = 32;
		generationText.color = FlxColor.BLACK;
		add(generationText);
		currentGeneration = 0;
		
		livingCellsText = new FlxText(0, FlxG.height * 0.95);
		livingCellsText.size = 32;
		livingCellsText.color = FlxColor.BLACK;
		livingCellsText.screenCenter(FlxAxes.X);
		livingCellsText.y -= livingCellsText.height;
		add(livingCellsText);
		
		livingCells = [];
		cellChanges = [];
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		livingCellsText.text = Std.string(livingCells.length);
		livingCellsText.screenCenter(FlxAxes.X);
		
		// Handle input
		if (FlxG.mouse.justPressed) {
			addGlider(FlxG.mouse.x, FlxG.mouse.y);
			sprite.dirty = true;
		}
		if (FlxG.mouse.justPressedRight) {
			simulationRunning = !simulationRunning;
		}
		
		// If the simulation isn't running, do not step the simulation
		if (!simulationRunning) {
			return;
		}
		
		timestepCounter += dt;
		if (timestepCounter < simulationTimestepSeconds) {
			return;
		}
		timestepCounter = 0;
		
		step();
	}
	
	/**
	 * Advances to the next generation of the game/simulation.
	 */
	private function step():Void {
		// Apply all the cell changes to the simulation
		for (change in cellChanges) {
			switch(change) {
				case CellChange.SPAWNED(x, y):
					var cell:Cell = Lambda.find(livingCells, function(cell:Cell) {
						return cell.x == x && cell.y == y;
					});
					if (cell != null) {
						continue;
					}
					livingCells.push(new Cell(x, y));
					sprite.graphic.bitmap.setPixel32(x, y, liveCellColor);
				case CellChange.DIED(x, y):
					var cell:Cell = Lambda.find(livingCells, function(cell:Cell) {
						return cell.x == x && cell.y == y;
					});
					Sure.sure(cell != null);
					livingCells.remove(cell);
					sprite.graphic.bitmap.setPixel32(x, y, deadCellColor);
			}
		}
		cellChanges.splice(0, cellChanges.length);
		
		// Update the active cells
		for (cell in livingCells) {
			updateCell(cell.x, cell.y, sprite.graphic.bitmap);
		}
		
		sprite.dirty = true;
		currentGeneration++;
	}
	
	/**
	 * Updates a cell.
	 * @param	x	The x-coordinate of the cell in the world.
	 * @param	y	The y-coordinate of the cell in the world.
	 * @param	state	The world.
	 */
	private function updateCell(x:Int, y:Int, state:BitmapData):Void {
		// Get the number of living cells that neighbor the given cell.
		var neighbourCount:Int = getLivingNeighborCount(x, y);
		
		if (neighbourCount <= 1 || neighbourCount >= 4) { // Death by underpopulation or overcrowding
			cellChanges.push(CellChange.DIED(x, y));
		}
		
		// Check all surrounding cells, spawning them if they have exactly three live neighbours.
		spawnHelper(x - 1, y - 1);
		spawnHelper(x, y - 1);
		spawnHelper(x + 1, y - 1);
		spawnHelper(x + 1, y);
		spawnHelper(x + 1, y + 1);
		spawnHelper(x, y + 1);
		spawnHelper(x - 1, y + 1);
		spawnHelper(x - 1, y);
	}
	
	/**
	 * Gets the number of living cells that neighbor the given cell.
	 * @param	x	The x-coordinate of the cell in the world.
	 * @param	y	The y-coordinate of the cell in the world.
	 * @param	state	The world.
	 * @return	The number of living cells that neighbor the given cell.
	 */
	private function getLivingNeighborCount(x:Int, y:Int):UInt {
		var count:UInt = 0;
		
		var state = sprite.graphic.bitmap;
		
		count += isAliveHelper(state.getPixel32(x - 1, y - 1));
		count += isAliveHelper(state.getPixel32(x, y - 1));
		count += isAliveHelper(state.getPixel32(x + 1, y - 1));
		count += isAliveHelper(state.getPixel32(x + 1, y));
		count += isAliveHelper(state.getPixel32(x + 1, y + 1));
		count += isAliveHelper(state.getPixel32(x, y + 1));
		count += isAliveHelper(state.getPixel32(x - 1, y + 1));
		count += isAliveHelper(state.getPixel32(x - 1, y));
		
		return count;
	}
	
	/**
	 * Helper method for determining whether a cell with a given color is alive or not.
	 * @param	pixel	The cell color.
	 * @return	1 if the cell is alive, 0 if it is not.
	 */
	private static inline function isAliveHelper(pixel:UInt):Int {
		return pixel == GameOfLifeDemo.liveCellColor ? 1 : 0;
	}
	
	/**
	 * Helper method for spawning cells if they are not currently alive and have three living neighbors.
	 * @param	x	The x-coordinate of the cell in the world.
	 * @param	y	The y-coordinate of the cell in the world.
	 * @param	state	The world.
	 */
	private function spawnHelper(x:Int, y:Int):Void {
		if (isAliveHelper(sprite.graphic.bitmap.getPixel32(x, y)) == 0 && getLivingNeighborCount(x, y) == 3) {
			cellChanges.push(CellChange.SPAWNED(x, y));
		}
	}
	
	/**
	 * Adds a glider to the world.
	 * @param	x	The x-coordinate of the glider (top left cell).
	 * @param	y	The y-coordinate of the glider (top left cell).
	 */
	private function addGlider(x:Int, y:Int):Void {
		addCell(x + 1, y);
		addCell(x + 2, y + 1);
		addCell(x, y + 2);
		addCell(x + 1, y + 2);
		addCell(x + 2, y + 2);
	}
	
	/**
	 * Adds a Game of Life pattern to the world.
	 * @param	pattern	The pattern, see the Patterns class.
	 * @param	x	The x-coordinate of the pattern (top left cell).
	 * @param	y	The y-coordinate of the pattern (top left cell).
	 * @param	width	The width of the pattern (must match the pattern string).
	 * @param	height	The height of the pattern (must match the pattern string).
	 */
	private function addPattern(pattern:String, x:Int, y:Int, width:UInt, height:UInt):Void {
		for (offsetX in 0...width) {
			for (offsetY in 0...height) {
				if (Std.parseInt(pattern.charAt(offsetX + width * offsetY)) == 1) {
					addCell(x + offsetX, y + offsetY);
				}
			}
		}
	}
	
	/**
	 * Helper function that adds a live cell to the world.
	 * @param	x	The x-coordinate of the cell in the world.
	 * @param	y	The y-coordinate of the cell in the world.
	 */
	private function addCell(x:Int, y:Int):Void {
		livingCells.push(new Cell(x, y));
		sprite.graphic.bitmap.setPixel32(x, y, liveCellColor);
	}
	
	/**
	 * Sets the current generation of the simulation.
	 * @param	generation	The generation of the simulation to change to.
	 * @return	The generation the simulation was changed to.
	 */
	private function set_currentGeneration(generation:UInt):UInt {
		this.currentGeneration = generation;
		if (generationText != null) {
			// Update the onscreen text showing the generation number
			generationText.text = Std.string(generation);
			generationText.screenCenter(FlxAxes.X);
		}
		return this.currentGeneration;
	}
}

/**
 * Represents a cell in Conway's Game of Life.
 */
class Cell {
	public var x(default, null):Int;
	public var y(default, null):Int;
	
	public inline function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}
}

/**
 * Represents a change to a cell in Conway's Game of Life (birth or death).
 */
enum CellChange {
	SPAWNED(x:Int, y:Int);
	DIED(x:Int, y:Int);
}

/**
 * Holds some common Game of Life patterns using string representations. 0 = dead, 1 = alive
 */
class Patterns {
	// Oscillators
	
	public static inline var BLINKER =
	'
	00000
	00000
	01110
	00000
	00000
	';
	
	public static inline var TOAD2 =
	'
	000000
	000100
	010010
	010010
	001000
	000000
	';
	
	public static inline var BEACON2 =
	'
	000000
	011000
	010000
	000010
	000110
	000000
	';
	
	// Spaceships
	
	public static inline var GLIDER =
	'
	010
	001
	111
	';
	
	// Puffer trains
	
	// ... TODO
	
	// Still life
	
	public static inline var BLOCK =
	'
	0000
	0110
	0110
	0000
	';
	
	public static inline var BEEHIVE =
	'
	000000
	001100
	010010
	001100
	000000
	';
	
	public static inline var LOAF =
	'
	000000
	001100
	010010
	001010
	000100
	000000
	';
	
	public static inline var BOAT =
	'
	00000
	01100
	01010
	00100
	00000
	';
}