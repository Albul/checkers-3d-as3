package events {
	import flash.events.Event;
	import pages.BasePage;
	
	/**
	 * ...
	 * @author Romanko Denis (Stormit) http://xitri.com
	 */
	public class PageEvent extends Event {
		
		static public const SHOW_COMPLETE:String = "showComplete";
		static public const HIDE_COMPLETE:String = "hideComplete";
		static public const NEED_PAGE:String = "needPage";
		public var pageClass:Class;
		public var nameClass:String;
		
		public function PageEvent(_type:String, _pageClass:Class = null, nameClass:String = null) {
			super(_type, false, false);
			this.nameClass = nameClass;
			pageClass = _pageClass;
		}
		
	}
	
}