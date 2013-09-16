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
package  {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import flash.display3D.Context3D;
	
	/**
	 * Класс отвечает за загрузку и расстановку графики на сцене
	 */
	public class Graphic extends Object {
		
		[Embed(source = "../res/board.A3D", mimeType = "application/octet-stream")] static private var mBoard:Class;
		[Embed(source = "../res/images/board.png")] static private var bBoard:Class;
		
		
		// Размеры шашки
		static public var WIDTH_CHECKER:Number;
		static public var HEIGHT_CHECKER:Number;
		
		private var rootContainer:Object3D;		// Корневой контейнер куда добавляем всю графику
		private var blackChecker:Mesh;			// Меш черной шашки
		private var whiteChecker:Mesh;			// Меш белой шашки
		
		private var _structCells:Object = new Object();		// Структура клеток
		private var _arrWhiteCheckers:Array;				// Массив белых шашек
		private var _arrBlackCheckers:Array;  				// Массив черных шашек
		private var _arrAllCheckers:Array;  				// Массив всех шашек
		
		public function Graphic(rootContainer:Object3D, context:Context3D) {
			this.rootContainer = rootContainer;
			
			var parser:ParserA3D = new ParserA3D();
			parser.parse(new mBoard());

			var rBoard:BitmapTextureResource = new BitmapTextureResource(new bBoard().bitmapData);
			var tBoard:VertexLightTextureMaterial = new VertexLightTextureMaterial(rBoard);
			rBoard.upload(context);
			
			
			for each (var object:Object3D in parser.objects) {
				
				var mesh:Mesh = object as Mesh;
				
				if (mesh == null) {		
					continue;
				}
					
				mesh.setMaterialToAllSurfaces(tBoard);
				
				if (mesh.name == "White") {						// Белая шашка
					this.whiteChecker = mesh;											
			
					// Запоминаем размеры шашки
					Graphic.WIDTH_CHECKER = mesh.boundBox.maxX - mesh.boundBox.minX;  	// Ширина шашки
					Graphic.HEIGHT_CHECKER = mesh.boundBox.maxZ - mesh.boundBox.minZ;  	// Высота шашки
				}		
				
				
				if (mesh.name == "Black") {						// Черная шашка
					this.blackChecker = mesh;
				}	
				
				
				if (mesh.name == "Board") {						// Игровая доска
					this.rootContainer.addChild(mesh);
				}
		
				
				// Добавление клеток на доску
				if (mesh.name.substr(3, 4) == "cell") {	
					var cell:Cell = new Cell(mesh, mesh.name);	// Создаем клетку
					this.structCells[cell.getIndex()] = cell;	// Заносим в структуру клеток
					this.rootContainer.addChild(cell);			// Добавляем на сцену
				}
			
				
				uploadResources(mesh.getResources(false, Geometry), context);
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Расставить шашки на доске
		 */
		public function arrangeCheckers():void {
			
			this._arrWhiteCheckers = new Array();	// Массив белых шашек
			this._arrBlackCheckers = new Array();   // Массив черных шашек
			this._arrAllCheckers = new Array();   	// Массив всех шашек
			
			//----------------------------------
			//  Расстановка белых шашек
			//----------------------------------
			var i:int = 1;
			var j:int = 1;
			var checker:Checker;
			var currentCell:Cell;
			
			// Проходим первые три ряда (для белых)
			while (i <= 3) {
				while (j <= 8) {
					checker = new Checker(this.whiteChecker.clone(), Logic.WHITE_TEAM);		// Создаем шашку
					currentCell = this.structCells[String(i) + String(j)];					// Берем нужную клетку из структуры
					
					checker.moveTo(currentCell, true); 			// Помещаем шашку на выбраную клетку
					
					this.rootContainer.addChild(checker);		// Добавляем шашку в главный контейнер
					this._arrWhiteCheckers.push(checker);		// Добавляем шашку в массив белых шашек
					this._arrAllCheckers.push(checker);			// Добавляем шашку в массив всех шашек
										
					j += 2;
				}
				
				i++;
				j = (i % 2 == 0)? 2 : 1;	// Розставляем только на черные клетки, поэтому если рядок парный тогда столбец непарный, и наоборот
			}
			//----------------------------------
			
			
			//----------------------------------
			//  Расстановка черных шашек
			//----------------------------------
			i = 8;
			j = 2;
			
			// Проходим последние три ряда (для черных)
			while (i >= 6) {
				while (j <= 8) {
					checker = new Checker(this.blackChecker.clone(), Logic.BLACK_TEAM);
					currentCell = this.structCells[String(i) + String(j)];
					
					checker.moveTo(currentCell, true); 			// Помещаем шашку на выбраную клетку
					
					this.rootContainer.addChild(checker);
					this._arrBlackCheckers.push(checker);
					this._arrAllCheckers.push(checker);			// Добавляем шашку в массив всех шашек

					j += 2;
				}
				
				i--;
				j = (i % 2 == 0)? 2 : 1;
			}
			//----------------------------------
		}
		
		
		/**
		 * Переустановить шашки на доске
		 */
		public function resetCheckers():void {
			
			// Сначала удаляем все шашки из сцены
			while (this._arrAllCheckers.length > 0) {
				this.rootContainer.removeChild(this._arrAllCheckers.pop());
			}
			
			/*for (var i:int = 0; i < this.rootContainer.numChildren; i++) {
				if (this.rootContainer.getChildAt(i) is Checker) {
					this.rootContainer.removeChildAt(i);
				}
			}*/
			
			// Проходим по всем клеткам и делаем их свободными
			for each (var cell:Cell in this._structCells) {
				cell.currentChecker = null;
				cell.isOccupied = null;
			}
			
			// Делаем новую растановку шашек
			arrangeCheckers();
		}
		
		
		public function get structCells():Object {
			return _structCells;
		}
		
		public function get arrWhiteCheckers():Array {
			return _arrWhiteCheckers;
		}
		
		public function get arrBlackCheckers():Array {
			return _arrBlackCheckers;
		}
		
		
		/**
		 * @private
		 * Загрузка ресурсов у контекст
		 */
		private function uploadResources(resources:Vector.<Resource>, context:Context3D):void {
			for each (var resource:Resource in resources) {
				resource.upload(context);
			}
		}
		
		
	}

}