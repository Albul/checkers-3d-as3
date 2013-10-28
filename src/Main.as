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
		
		private var cameraContainer:Object3D = new Object3D();
		private var rootContainer:Object3D = new Object3D();
		private var controller:SimpleObjectController;
		private var camera:Camera3D;
		private var stage3D:Stage3D;
		
		private var directionalLight:DirectionalLight;
		private var ambientLight:AmbientLight;
				
		private var graphic:Graphic;							// Responsible for the arrangement graphs
		private var logic:Logic;								// Responsible for game logic
		private var informer:Informer;							// Responsible for the output of information
		private var pageManager:PageManager;					// Responsible for displaying the game menu
		
		private var isStart:Boolean;
		private var settings:Object;							// The structure saves the game settings
		
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
			
			// Creating the menu
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

		private function startGame():void {
			settings = SettingsPage(pageManager.getPage(SettingsPage)).getSettings();
			
			this.isStart = true;

			// Camera and view -----------------
			camera = new Camera3D(0.01, 10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x404060, 0, 4);
			camera.view.antiAlias = settings["quality"];
			camera.z = -100;
			camera.view.hideLogo();
			addChild(camera.view);
			cameraContainer.addChild(camera);
			this.rootContainer.addChild(cameraContainer);
			//----------------------------------

			// Controller ----------------------
			controller = new SimpleObjectController(camera.view, cameraContainer, 400);
			controller.lookAtXYZ(0, 0, 0);
			controller.unbindAll();
			cameraContainer.rotationX = MathUtils.toRadians(-130);		// In order to look at the board from a height
			// Orient the camera to the selected team color
			cameraContainer.rotationZ = settings["team"]? MathUtils.toRadians(180): MathUtils.toRadians(0);
			controller.updateObjectTransform();
			//----------------------------------

			// Light ---------------------------
			directionalLight = new DirectionalLight(0xffffff);
			directionalLight.z = 300;
			directionalLight.intensity = 0.5;
			directionalLight.lookAt(0, 0, 0);
			this.rootContainer.addChild(directionalLight);		
						
			ambientLight = new AmbientLight(0xFFFFFF);
			ambientLight.intensity = 0.4;
			this.rootContainer.addChild(ambientLight);
			//----------------------------------

			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
		}

		private function restartGame():void {
			settings = SettingsPage(pageManager.getPage(SettingsPage)).getSettings();
			camera.view.antiAlias = settings["quality"];
			addChild(camera.view);
			// Orient the camera to the selected team color
			cameraContainer.rotationZ = settings["team"]? MathUtils.toRadians(180): MathUtils.toRadians(0);
			controller.updateObjectTransform();
			graphic.resetCheckers();
			createLogic();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function createLogic():void {
			this.logic = new Logic(graphic.structCells, graphic.arrWhiteCheckers, graphic.arrBlackCheckers,
					settings["team"], settings["level"]);
			
			informer = new Informer(logic);
			informer.y = 1;
			informer.x = stage.stageWidth - informer.width - 1;
			stage.addChild(informer);
			
			informer.addEventListener(Informer.END_GAME, onEndGame);
		}

		private function cameraZoomIn():void {
			if (camera.z < -30) 				// Set the limit on the zoom
				camera.z += 10;
		}		

		private function cameraZoomOut():void {
			if (camera.z > -150) 
				camera.z -= 10;
		}

		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------


		private function onPageChange(e:PageEvent):void {
			if (e.nameClass == "GamePage") {
				if (!this.isStart) {
					startGame();
				}
				else {
					restartGame();
				}
			}
		}
		
		/**
		 * Context is available
		 */
		private function onContextCreate(e:Event):void {
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			
			this.graphic = new Graphic(this.rootContainer, this.stage3D.context3D);
			graphic.arrangeCheckers();
			
			createLogic();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			camera.view.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);		// For the zoom of camera
		}

		public function onEndGame(e:Event):void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (this.contains(camera.view))
				this.removeChild(camera.view);
			this.stage3D.context3D.clear(246, 245, 22);
			this.stage3D.context3D.present();
			
			pageManager.showPage(MenuPage);
		}

		private function onResize(e:Event):void {
			if (this.isStart) {
				camera.view.width = stage.stageWidth;
				camera.view.height = stage.stageHeight;
				informer.x = stage.stageWidth - informer.width - 1;		// Set the informer in the top right corner
			}
			
			// Set the main menu on the center of the stage
			pageManager._x = (stage.stageWidth - pageManager.width) / 2;
			pageManager._y = (stage.stageHeight - pageManager.height) / 2;
		}

		/**
		 * Use the scroll zoom in and zoom out the camera
		 */
		private function onMouseWheel(e:MouseEvent):void {
			if (e.delta > 0) 
				cameraZoomIn();
			if (e.delta < 0)
				cameraZoomOut();
		}

		private function onEnterFrame(e:Event):void {
			controller.update();
			camera.render(stage3D);
		}
		
		
	}
}