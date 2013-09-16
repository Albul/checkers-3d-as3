package pages {
	import events.PageEvent;
	import fl.controls.ComboBox;
	import fl.controls.Slider;
	import fl.data.DataProvider;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Настройки игры
	 */
	public class SettingsPage extends BasePage {
		
		private var btnBack:SimpleButton;
		private var cbTeam:ComboBox;
		private var cbLevel:ComboBox;
		private var sQuality:Slider;
		
		public function SettingsPage(_vis:Sprite) {
			super(_vis);
			
			btnBack = visual.getChildByName("btnBack") as SimpleButton;
			btnBack.addEventListener(MouseEvent.CLICK, btnClickHandler);
			
			cbTeam = visual.getChildByName("cbTeam") as ComboBox;
			cbLevel = visual.getChildByName("cbLevel") as ComboBox;
			sQuality = visual.getChildByName("sQuality") as Slider;
		}
		
		
		/**
		 * Возвращает выбранные настройки пользователя
		 * @return
		 */
		public function getSettings():Object {
			var obj:Object = new Object();
			obj["team"] = (cbTeam.selectedIndex <= 0? Logic.WHITE_TEAM: Logic.BLACK_TEAM);		// Цвет команды за которую играет игрок
			obj["level"] = (cbLevel.selectedIndex <= 0? 1: cbLevel.selectedIndex + 1);			// Уровень сложности компьютера
			obj["quality"] = sQuality.value;													// Качество видео
			return obj;
		}
		
		private function showStyleDefinition(e:Event):void {
			
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