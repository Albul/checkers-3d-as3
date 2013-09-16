package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Romanko Denis (Stormit) http://xitri.com
	 */
	public class Preloader extends MovieClip {
		private var visual:PreloaderComponent;
		private var indicator:Sprite;
		
		public function Preloader() {
			addEventListener(Event.ENTER_FRAME, checkFrame);
			// show loader
			
			visual = new PreloaderComponent();
			indicator = visual.getChildByName("indicator") as Sprite;
			
			addChild(visual);
			visual.x = stage.stageWidth / 2;
			visual.y = stage.stageHeight / 2;
		}
		
		private function checkFrame(e:Event):void {
			// update loader
			var percent:Number = stage.loaderInfo.bytesLoaded / stage.loaderInfo.bytesTotal;
			indicator.scaleX = percent;
			
			if (currentFrame == totalFrames) {
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				startup();
			}
		}
		
		private function startup():void {
			// hide loader
			removeChild(visual);
			stop();
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}