package;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.states.LycanRootState;
import lycan.ui.layouts.Layout.Alignment;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.widgets.ListView;
import lycan.ui.widgets.buttons.IconButton;

using StringTools;

/**
 * Start state for the all-in-one Lycan demo and feature showcase/testbed.
 * Manages the main list of demos.
 */
class LycanDemoRootState extends LycanRootState {
	private var ui:ListView;
	public var uiGroup(default, null) = new FlxSpriteGroup();

	public function new() {
		super();
		persistentDraw = false;
		persistentUpdate = false;
		destroySubStates = true;
	}

	override public function create():Void {
		ui = new ListView();
		ui.layout = new VBoxLayout(5, Alignment.CENTER);
		ui.width = FlxG.width;
		ui.height = FlxG.height;
		uiRoot.topLevelWidget = ui;

		super.create();

		bgColor = FlxColor.WHITE;

		// TODO actually write a scrollable list view
		// TODO add an option that enters every demo state, takes a screenshot, and returns to the root state

		// Get all the classes in the demo packages that end with "Demo", sort them alphabetically, add named buttons which instantiates them when clicked (to launch a demo)
		CompileTime.importPackage("demo");
		var demos = Lambda.array(CompileTime.getAllClasses("demo"));
		demos.sort(function(a:Class<Dynamic>, b:Class<Dynamic>) {
			var sa = Type.getClassName(a).split(".");
			var sb = Type.getClassName(b).split(".");
			Sure.sure(sa.length == 2);
			Sure.sure(sb.length == 2);
			if (sa[sa.length - 1].toLowerCase() < sb[sb.length - 1].toLowerCase()) {
				return -1;
			}
			return 1;
		});

		Sure.sure(demos.length != 0);
		for (demo in demos) {
			var path = Type.getClassName(demo);
			Sure.sure(path.startsWith("demo"));
			var splitPath = path.split(".");
			Sure.sure(splitPath.length == 2);
			var className = splitPath[1];
			if (className.endsWith("Demo")) {
				var name = className.replace("Demo", "");
				addButton(demo, name);
			}
		}

		ui.updateGeometry();

		add(uiGroup);
	}

	private function addButton<T:BaseDemoState>(clazz:Class<T>, name:String):Void {
		var text = new FlxText(0, 0, 0, name, 32);
		text.color = FlxColor.BLACK;
		var button = new IconButton(text, ui);
		for (g in button.graphics) {
			uiGroup.add(g);
		}
		button.signal_clicked.add(function() {
            var instance = Type.createInstance(clazz, []);
			openSubState(instance);
		});
	}

	public function makeRootUiTopLevel():Void {
		uiRoot.topLevelWidget = ui;
	}
}