package managers {
	import events.PageEvent;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import pages.BasePage;
	
	/**
	 * ...
	 * @author Romanko Denis (Stormit) http://xitri.com
	 */
	public class PageManager extends Sprite{
		
		private var _pages:Dictionary;
		private var _currentPage:BasePage;
		private var newPage:BasePage;
		
		public function PageManager() {
			init();
		}
		
		protected function init():void{
			_pages = new Dictionary();
		}
		
		public function registerPage(page:BasePage):void {
			_pages[(page as Object).constructor] = page;
			page.addEventListener(PageEvent.NEED_PAGE, needPageHandler);
		}
		
		private function needPageHandler(e:PageEvent):void {
			showPage(e.pageClass);
		}
		
		public function getPage(pageClass:Class):BasePage {
			return _pages[pageClass];
		}
		
		public function showPage(pageClass:Class):void {
			newPage = getPage(pageClass);
			
			if (_currentPage) {
				_currentPage.addEventListener(PageEvent.HIDE_COMPLETE, hideCompleteHandler);
				_currentPage.hide();
			} else {
				hideCompleteHandler(new PageEvent(""));
			}
		}
		
		private function hideCompleteHandler(e:PageEvent):void {
			if (_currentPage) {
				_currentPage.removeEventListener(PageEvent.HIDE_COMPLETE, hideCompleteHandler);
				//removeChild(_currentPage);
			}
			addChild(newPage);
			newPage.show();
			_currentPage = newPage;
		}
		
		public function set _x(value:Number):void {
			for each (var page:BasePage in _pages) {
				page.x = value;
			}
		}	
		
		public function set _y(value:Number):void {
			for each (var page:BasePage in _pages) {
				page.y = value;
			}
		}
		

		
	}
	
}