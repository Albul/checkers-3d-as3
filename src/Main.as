/*
 * 
 * Copyright (c) 2012, Albul Alexandr
 
 This file is part of Checkers3D.

    Checkers3D is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see < http://www.gnu.org/licenses/>.
*/
package {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	
	import com.MathUtils;
	
	import events.PageEvent;
	import flash.events.MouseEvent;
	import managers.PageManager;
	import pages.AuthorsPage;
	import pages.GamePage;
	import pages.LanPage;
	import pages.MenuPage;
	import pages.SettingsPage;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode
	import flash.events.Event;

	[SWF(width = "800", height = "600", backgroundColor = "#404060")] 
	
	public class Main extends Sprite {
		
		private var cameraContainer:Object3D = new Object3D();	// Контейнер камеры. Камера будет вложена в него. А он будет вложен в  rootContainer		
		private var rootContainer:Object3D = new Object3D();
		private var controller:SimpleObjectController;
		private var camera:Camera3D;
		private var stage3D:Stage3D;
		
		private var directionalLight:DirectionalLight;			// Направленный источник света
		private var ambientLight:AmbientLight;
				
		private var graphic:Graphic;							// Отвечает  за расстановку графики
		private var logic:Logic;								// Отвечает за логику игры
		private var informer:Informer;							// Отвечает за вывод информации		
		private var pageManager:PageManager;					// Отвечает за отображение меню игры	
		
		private var isStart:Boolean;							// Указывает на то была ли инициализирована игра
		private var settings:Object;							// Структура сохраняет настройки игры	
		
		public function Main() {	
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			pageManager = new PageManager();
			addChild(pageManager);
			
			// Создаем менюшку
			var menuPage:MenuPage = new MenuPage(new MenuComponent());
			pageManager.registerPage(menuPage);
			pageManager.registerPage(new LanPage(new LanComponent()));
			pageManager.registerPage(new SettingsPage(new SettingsComponent()));
			pageManager.registerPage(new AuthorsPage(new AuthorsComponent()));
			pageManager.registerPage(new GamePage(new Sprite()));
			pageManager.showPage(MenuPage);
						
			menuPage.addEventListener(PageEvent.NEED_PAGE, onPageChange);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onPageChange(e:PageEvent):void {
			if (e.nameClass == "GamePage") {			// Если нужно показать страницу с игрой, то запускаем функцию инициализации игры
				if (!isStart) {
					startGame();
				}
				else {
					restartGame();
				}
				
			}
		}
				
		
		/**
		 * Инициализация игры
		 */
		private function startGame():void {
			settings = SettingsPage(pageManager.getPage(SettingsPage)).getSettings();
			
			isStart = true;
			
			//----------------------------------
			//  Камера и вьюпорт
			//----------------------------------
			camera = new Camera3D(0.01, 10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x404060, 0, 4);
			camera.view.antiAlias = settings["quality"];
			camera.z = -100;
			camera.view.hideLogo();
			addChild(camera.view);
			cameraContainer.addChild(camera);				// Добавляем камеру в контейнер камеры
			this.rootContainer.addChild(cameraContainer);	// Контейнер камеры в общий контейнер
			//----------------------------------
			
			
			
			//----------------------------------
			//  Контроллер
			//----------------------------------
			controller = new SimpleObjectController(camera.view, cameraContainer, 400);	// Добавляем контроллер объектов и привязываем его к контейнеру камеры
			controller.lookAtXYZ(0, 0, 0);
			controller.unbindAll();										// Поскольку нам нужен орбитальный просмотр объекта, нам будет достаточным управление мышью. Управление клавишами отключаем
			cameraContainer.rotationX = MathUtils.toRadians(-130);		// Поворачиваем контейнер чтобы смотреть на доску с высоты
			cameraContainer.rotationZ = settings["team"]? MathUtils.toRadians(180): MathUtils.toRadians(0);		// Поворачиваем контейнер чтобы смотреть на доску с той стороны где находятся шашки игрока
			controller.updateObjectTransform();
			//----------------------------------
			
			
			//----------------------------------
			//  Освещение
			//----------------------------------
			directionalLight = new DirectionalLight(0xffffff); 	// Создаем направленный источник света
			directionalLight.z = 300;
			directionalLight.intensity = 0.5;      				// Настраиваем интенсивность света
			directionalLight.lookAt(0, 0, 0);
			this.rootContainer.addChild(directionalLight);		
						
			ambientLight = new AmbientLight(0xFFFFFF);			// Создаем точечный источник света
			ambientLight.intensity = 0.4;					 	// Настраиваем интенсивность света
			this.rootContainer.addChild(ambientLight);
			//----------------------------------

			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);		// Запрашиваем контекст
			stage3D.requestContext3D();
		}

		
		/**
		 * Повторная инициализация игры
		 */
		private function restartGame():void {
			settings = SettingsPage(pageManager.getPage(SettingsPage)).getSettings();
			camera.view.antiAlias = settings["quality"];
			addChild(camera.view);	
			cameraContainer.rotationZ = settings["team"]? MathUtils.toRadians(180): MathUtils.toRadians(0);		// Поворачиваем контейнер чтобы смотреть на доску с той стороны где находятся шашки игрока
			controller.updateObjectTransform();
			graphic.resetCheckers();								// Переустанавливаем шашки на доске
			createLogic();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
					
		/**
		 * Создать класс логики игры, и информер
		 */
		private function createLogic():void {
			this.logic = new Logic(graphic.structCells, graphic.arrWhiteCheckers, graphic.arrBlackCheckers, settings["team"], settings["level"]);
			
			// Создание окна из информацией о состоянии игры
			informer = new Informer(logic);
			informer.y = 1;
			informer.x = stage.stageWidth - informer.width - 1;
			stage.addChild(informer);
			
			informer.addEventListener(Informer.END_GAME, onEndGame);		// Слушаем событие завершения игры
		}
		
		
		/**
		 * Приблизить камеру
		 */
		private function cameraZoomIn():void {
			if (camera.z < -30) 				// Накладываем ограничение на приближение
				camera.z += 10;
		}		
		
		
		/**
		 * Отдалить камеру
		 */
		private function cameraZoomOut():void {
			if (camera.z > -150) 
				camera.z -= 10;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Контекст доступен
		 */
		private function onContextCreate(e:Event):void {
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			
			this.graphic = new Graphic(this.rootContainer, this.stage3D.context3D);
			graphic.arrangeCheckers();
			
			createLogic();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			camera.view.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);		// Вешаем слушателя на вьюпорт будем приближать камеру
		}

				
		/**
		 * Завершение игры
		 */
		public function onEndGame(e:Event):void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);	// Отписываемся от рендеринга сцены
			if (this.contains(camera.view))
				this.removeChild(camera.view);						// Удалить вьюпорт из сцены		
			this.stage3D.context3D.clear(246, 245, 22);				// Очистить контекст
			this.stage3D.context3D.present();
			
			pageManager.showPage(MenuPage);							// Показать главную страницу меню
		}
		
		
		/**
		 * Изменение размера сцены
		 */
		private function onResize(e:Event):void {
			if (isStart) {
				// Ширина и высота вюпорта изменяется в зависимости от размера сцени
				camera.view.width = stage.stageWidth;
				camera.view.height = stage.stageHeight;
				informer.x = stage.stageWidth - informer.width - 1;		// Устанавливаем информер у верхний угол
			}
			
			// Выравниваем главное меню поцентру сцены
			pageManager._x = (stage.stageWidth - pageManager.width) / 2;
			pageManager._y = (stage.stageHeight - pageManager.height) / 2;
		}
		

		/**
		 * С помощью скролинга приближаем и отдаляем камеру
		 */
		private function onMouseWheel(e:MouseEvent):void {
			if (e.delta > 0) 
				cameraZoomIn();
			if (e.delta < 0)
				cameraZoomOut();
		}
		
		
		/**
		 * Рендерим сцену каждый кадр
		 */
		private function onEnterFrame(e:Event):void {
			controller.update();
			camera.render(stage3D);
		}
		
		
	}
}