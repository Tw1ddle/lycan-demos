package demo;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrailArea;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.tween.ease.EaseAtan;
import lycan.tween.ease.EaseBack;
import lycan.tween.ease.EaseBounce;
import lycan.tween.ease.EaseCircular;
import lycan.tween.ease.EaseCubic;
import lycan.tween.ease.EaseCubicHermite;
import lycan.tween.ease.EaseElastic;
import lycan.tween.ease.EaseExponential;
import lycan.tween.ease.EaseLinear;
import lycan.tween.ease.EaseQuadratic;
import lycan.tween.ease.EaseQuartic;
import lycan.tween.ease.EaseQuintic;
import lycan.tween.ease.EaseSinusoidal;
import lycan.util.timeline.Timeline;
import lycan.util.timeline.TweenItem;
import openfl.Lib;
import openfl.events.MouseEvent;

using flixel.util.FlxSpriteUtil;
using lycan.core.IntExtensions;
using lycan.core.FloatExtensions;

class TweenGraph extends FlxSpriteGroup {
	public var description:String;
	public var ease:Float->Float;

	public var box:FlxSprite;
	public var point:FlxSprite;
	public var trailPoint:FlxSprite;

	public var graphX:Float;
	public var graphY:Float;

	public function new(description:String, ease:Float->Float) {
		super();

		this.description = description;
		this.ease = ease;

		box = new FlxSprite().makeGraphic(Std.int(FlxG.width / EasingEquationsDemo.TWEENS_PER_ROW - EasingEquationsDemo.ITEM_SPACING * 2), Std.int(FlxG.height / 11 - EasingEquationsDemo.ITEM_SPACING * 2), FlxColor.WHITE);
		box.drawRect(box.x, box.y, box.width, box.height, FlxColor.TRANSPARENT, { thickness: 2, color: FlxColor.BLACK });
		add(box);

		var text = new FlxText(0, 0, 0, description, 8);
		text.color = FlxColor.GRAY;
		add(text);

		point = new FlxSprite();
		point.makeGraphic(6, 6, FlxColor.TRANSPARENT);
		point.drawCircle(3, 3, 3, FlxColor.RED);
		add(point);

		trailPoint = new FlxSprite();
		trailPoint.makeGraphic(2, 2, FlxColor.BLUE);
		add(trailPoint);

		text.setPosition(width / 2 - text.width / 2, height / 2 - text.height / 2);

		graphX = 0;
		graphY = 0;
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		point.x = graphX + x - point.width / 2;
		point.y = graphY + y - point.height / 2;

		trailPoint.x = graphX + x - trailPoint.width / 2;
		trailPoint.y = graphY + y - trailPoint.height / 2;
	}
}

class EasingEquationsDemo extends BaseDemoState {
	public static inline var TWEENS_PER_ROW:Int = 4;
	public static inline var ITEM_SPACING:Int = 4;

	public var rateMultiplier:Float = 1;

	private var timeline:Timeline<TweenGraph>;
	private var graphs:Array<TweenGraph>;
	private var graphGroup:FlxSpriteGroup;
	private var trailArea:FlxTrailArea;
	private var userControlled:Bool;
	private var reversed:Bool;

	override public function create():Void {
		super.create();

		bgColor = FlxColor.GRAY;

		timeline = new Timeline<TweenGraph>();
		graphs = new Array<TweenGraph>();
		graphGroup = new FlxSpriteGroup();
		trailArea = new FlxTrailArea(0, 0, FlxG.width, FlxG.height, 0.95, 1);
		userControlled = false;
		reversed = false;

		addTween(EaseQuadratic.inQuad, "EaseInQuad");
		addTween(EaseQuadratic.outQuad, "EaseOutQuad");
		addTween(EaseQuadratic.inOutQuad, "EaseInOutQuad");
		addTween(EaseQuadratic.outInQuad, "EaseOutInQuad");

		addTween(EaseCubic.inCubic, "EaseInCubic");
		addTween(EaseCubic.outCubic, "EaseOutCubic");
		addTween(EaseCubic.inOutCubic, "EaseInOutCubic");
		addTween(EaseCubic.outInCubic, "EaseOutInCubic");

		addTween(EaseQuartic.inQuart, "EaseInQuart");
		addTween(EaseQuartic.outQuart, "EaseOutQuart");
		addTween(EaseQuartic.inOutQuart, "EaseInOutQuart");
		addTween(EaseQuartic.outInQuart, "EaseOutInQuart");

		addTween(EaseQuintic.inQuint, "EaseInQuint");
		addTween(EaseQuintic.outQuint, "EaseOutQuint");
		addTween(EaseQuintic.inOutQuint, "EaseInOutQuint");
		addTween(EaseQuintic.outInQuint, "EaseOutInQuint");

		addTween(EaseSinusoidal.inSine, "EaseInSine");
		addTween(EaseSinusoidal.outSine, "EaseOutSine");
		addTween(EaseSinusoidal.inOutSine, "EaseInOutSine");
		addTween(EaseSinusoidal.inOutSine, "EaseOutInSine");

		addTween(EaseExponential.inExpo, "EaseInExpo");
		addTween(EaseExponential.outExpo, "EaseOutExpo");
		addTween(EaseExponential.inOutExpo, "EaseInOutExpo");
		addTween(EaseExponential.outInExpo, "EaseOutInExpo");

		addTween(EaseCircular.inCirc, "EaseInCirc");
		addTween(EaseCircular.outCirc, "EaseOutCirc");
		addTween(EaseCircular.inOutCirc, "EaseInOutCirc");
		addTween(EaseCircular.outInCirc, "EaseOutInCirc");

		addTween(EaseAtan.makeInAtan(), "EaseInAtan");
		addTween(EaseAtan.makeOutAtan(), "EaseOutAtan");
		addTween(EaseAtan.makeInOutAtan(), "EaseInOutAtan");
		addTween(EaseLinear.none, "EaseLinear");

		addTween(EaseBack.makeInBack(), "EaseInBack");
		addTween(EaseBack.makeOutBack(), "EaseOutBack");
		addTween(EaseBack.makeInOutBack(), "EaseInOutBack");
		addTween(EaseBack.makeOutInBack(), "EaseOutInBack");

		addTween(EaseBounce.makeInBounce(), "EaseInBounce");
		addTween(EaseBounce.makeOutBounce(), "EaseOutBounce");
		addTween(EaseBounce.makeInOutBounce(), "EaseInOutBounce");
		addTween(EaseBounce.makeOutInBounce(), "EaseOutInBounce");

		addTween(EaseElastic.makeInElastic(2, 1), "EaseInElastic(2, 1)");
		addTween(EaseElastic.makeOutElastic(1, 4), "EaseOutElastic(1, 4)");
		addTween(EaseElastic.makeInOutElastic(2, 1), "EaseInOutElastic(2, 1)");
		addTween(EaseElastic.makeOutInElastic(1, 4), "EaseOutInElastic(1, 4)");

		addTween(EaseCubicHermite.makeHermite(0.2, 0.6, 0.2), "EaseCubicHermite(0.2, 0.6, 0.2)");
		addTween(EaseCubicHermite.makeHermite(0.4, 0.2, 0.4), "EaseCubicHermite(0.4, 0.2, 0.4)");
		addTween(EaseCubicHermite.makeHermite(0.5, 0.3, 0.2), "EaseCubicHermite(0.5, 0.3, 0.2)");
		addTween(EaseCubicHermite.makeHermite(0.2, 0.3, 0.5), "EaseCubicHermite(0.2, 0.3, 0.5)");

		var i:Int = 0;
		var x:Float = 0;
		var y:Float = 0;
		for (graph in graphs) {
			timeline.add(new TweenItem(graph, 0, 1, [ TweenItem.makeTweener("graphX").bind(0.0, graph.width) ], EaseLinear.none));
			timeline.add(new TweenItem(graph, 0, 1, [ TweenItem.makeTweener("graphY").bind(graph.height, 0.0) ], graph.ease));

			i++;
			graph.x = x;
			x += graph.width + ITEM_SPACING;
			graph.y = y;
			if (i % EasingEquationsDemo.TWEENS_PER_ROW == 0) {
				x = 0;
				y += graph.height + ITEM_SPACING;
			}
			graphGroup.add(graph);
			trailArea.add(graph.trailPoint);
		}

		graphGroup.screenCenter();
		add(graphGroup);
		add(trailArea);

		for (graph in graphs) {
			add(graph.point);
		}

		Lib.current.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):Void {
			reversed = !reversed;
		});

		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, function(e:MouseEvent):Void {
			userControlled = !userControlled;
		});

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent):Void {
			if (e.delta > 0) {
				rateMultiplier += 0.1;
			} else if (e.delta < 0) {
				rateMultiplier -= 0.1;
			}
		});
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		if (!userControlled) {
			if (timeline.currentTime >= 1) {
				timeline.reset();
				timeline.currentTime = 0;
			} else if (timeline.currentTime <= 0) {
				timeline.reset();
				timeline.currentTime = 1;
			}
			timeline.step(reversed ? -dt * rateMultiplier : dt * rateMultiplier);
		} else {
			timeline.stepTo((FlxG.mouse.x.clamp(1, FlxG.width) / FlxG.width).clamp(0, 1));
		}
	}

	private inline function addTween(ease:Float->Float, description:String):Void {
		var graph = new TweenGraph(description, ease);
		graphs.push(graph);
	}
}