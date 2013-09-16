package pages {
	import events.PageEvent;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Romanko Denis (Stormit) http://xitri.com
	 */
	public class MenuPage extends BasePage{
		private var btnPlay:SimpleButton;
		private var btnLan:SimpleButton;
		private var btnSettings:SimpleButton;
		private var btnHighscores:SimpleButton;
		private var btnAuthors:SimpleButton;
		
		public function MenuPage(_vis:Sprite) {
			super(_vis);
			
			btnPlay = visual.getChildByName("btnPlay") as SimpleButton;
			btnPlay.addEventListener(MouseEvent.CLICK, btnClickHandler);
			
			btnLan = visual.getChildByName("btnLan") as SimpleButton;
			btnLan.addEventListener(MouseEvent.CLICK, btnClickHandler);
			
			btnSettings = visual.getChildByName("btnSettings") as SimpleButton;
			btnSettings.addEventListener(MouseEvent.CLICK, btnClickHandler);
			
			btnAuthors = visual.getChildByName("btnAuthors") as SimpleButton;
			btnAuthors.addEventListener(MouseEvent.CLICK, btnClickHandler);
		}
		
		private function btnClickHandler(e:MouseEvent):void {
			switch (e.currentTarget) {
				case btnPlay:
				dispatchEvent(new PageEvent(PageEvent.NEED_PAGE, GamePage, "GamePage"));
				break;
				
				case btnLan:
				dispatchEvent(new PageEvent(PageEvent.NEED_PAGE, LanPage));
				break;
				
				case btnSettings:
				dispatchEvent(new PageEvent(PageEvent.NEED_PAGE, SettingsPage, "SettingsPage"));
				break;
				
				case btnAuthors:
				dispatchEvent(new PageEvent(PageEvent.NEED_PAGE, AuthorsPage));
				break;
			}
		}
		
	}
	
}