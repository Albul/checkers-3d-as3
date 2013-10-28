package pages {
	import events.PageEvent;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class AuthorsPage extends BasePage {
		
		private var btnBack:SimpleButton;
		
		public function AuthorsPage(_vis:Sprite) {
			super(_vis);
			
			btnBack = visual.getChildByName("btnBack") as SimpleButton;
			btnBack.addEventListener(MouseEvent.CLICK, btnClickHandler);
		}
		
		private function btnClickHandler(e:MouseEvent):void {
			switch (e.currentTarget) {
				case btnBack:
				dispatchEvent(new PageEvent(PageEvent.NEED_PAGE, MenuPage));
				break;
			}
		}
		
	}
}