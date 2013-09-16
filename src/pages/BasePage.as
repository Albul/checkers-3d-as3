package pages {
	import events.PageEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Romanko Denis (Stormit) http://xitri.com
	 */
	public class BasePage extends Sprite {
		protected var _visual:Sprite;
		
		public function BasePage(_vis:Sprite) {
			_visual = _vis;
			addChild(_visual);
		}
		
		public function show():void {
			visual.alpha = 0;
			addEventListener(Event.ENTER_FRAME, showStep);
		}
		
		public function hide():void {
			visual.alpha = 1;
			addEventListener(Event.ENTER_FRAME, hideStep);
		}
		
		private function hideStep(e:Event):void{
			visual.alpha -= .2;
			if (visual.alpha <= 0) {
				visual.alpha = 0;
				removeEventListener(Event.ENTER_FRAME, hideStep);
				dispatchEvent(new PageEvent(PageEvent.HIDE_COMPLETE));
			}
		}
		
		private function showStep(e:Event):void{
			visual.alpha += .2;
			if (visual.alpha >= 1) {
				visual.alpha = 1;
				removeEventListener(Event.ENTER_FRAME, showStep);
				dispatchEvent(new PageEvent(PageEvent.SHOW_COMPLETE));
			}
		}
		
		public function get visual():Sprite { return _visual; }
		
	}
	
}