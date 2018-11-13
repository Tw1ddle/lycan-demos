package;

import flixel.FlxG;
import lycan.states.LycanRootState;
import lycan.states.LycanState;
import lycan.ui.widgets.Widget;

class BaseDemoState extends LycanState {
	private var game(default, null):LycanDemoRootState;
	private var ui(default, null):Widget = null;

	public function new() {
		super();
		game = cast LycanRootState.get;
		trace("Root state is " + game);
	}

	override public function create():Void {
		super.create();

		// If a subclass did not instantiate a UI then set a default one here
		if (ui == null) {
			ui = new Widget(null, Type.getClassName(Type.getClass(this)) + "_ui_root");
			ui.x = 0;
			ui.y = 0;
			ui.width = FlxG.width;
			ui.height = FlxG.height;
			ui.paddingLeft = 10;
			ui.paddingBottom = 10;
			ui.paddingRight = 10;
			ui.paddingTop = 10;
		}

		game.uiRoot.topLevelWidget = ui;
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		if (FlxG.keys.justPressed.BACKSPACE) {
			close();
		}
	}

	override public function close():Void {
		if (_parentState == game) {
			game.makeRootUiTopLevel();
		}

		super.close();
	}
}