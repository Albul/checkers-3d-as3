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
	 * Class is responsible for loading and arrangement graphics on the stage
	 */
	public class Graphic extends Object {
		
		[Embed(source = "../res/board.A3D", mimeType = "application/octet-stream")] static private var mBoard:Class;
		[Embed(source = "../res/images/board.png")] static private var bBoard:Class;

		static public var WIDTH_CHECKER:Number;
		static public var HEIGHT_CHECKER:Number;
		
		private var rootContainer:Object3D;
		private var blackChecker:Mesh;
		private var whiteChecker:Mesh;
		
		private var _structCells:Object = new Object();
		private var _arrWhiteCheckers:Array;
		private var _arrBlackCheckers:Array;
		private var _arrAllCheckers:Array;
		
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
				
				if (mesh.name == "White") {     // White checker
					this.whiteChecker = mesh;											
			
					// Remember the size of checker
					Graphic.WIDTH_CHECKER = mesh.boundBox.maxX - mesh.boundBox.minX;
					Graphic.HEIGHT_CHECKER = mesh.boundBox.maxZ - mesh.boundBox.minZ;
				}		

				if (mesh.name == "Black") {     // Black checker
					this.blackChecker = mesh;
				}	

				if (mesh.name == "Board") {     // Game board
					this.rootContainer.addChild(mesh);
				}

				// Adding cells to the board
				if (mesh.name.substr(3, 4) == "cell") {	
					var cell:Cell = new Cell(mesh, mesh.name);
					this.structCells[cell.getIndex()] = cell;
					this.rootContainer.addChild(cell);
				}

				uploadResources(mesh.getResources(false, Geometry), context);
			}
		}
		

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		

		public function arrangeCheckers():void {
			
			this._arrWhiteCheckers = new Array();
			this._arrBlackCheckers = new Array();
			this._arrAllCheckers = new Array();

			// Arrangement of white checkers ---
			var i:int = 1;
			var j:int = 1;
			var checker:Checker;
			var currentCell:Cell;

			while (i <= 3) {
				while (j <= 8) {
					checker = new Checker(this.whiteChecker.clone(), Logic.WHITE_TEAM);
					currentCell = this.structCells[String(i) + String(j)];
					
					checker.moveTo(currentCell, true);
					
					this.rootContainer.addChild(checker);
					this._arrWhiteCheckers.push(checker);
					this._arrAllCheckers.push(checker);
										
					j += 2;
				}
				
				i++;
				j = (i % 2 == 0)? 2 : 1;	// Set only on the black cells
			}
			//----------------------------------

			// Arrangement of black checkers ---
			i = 8;
			j = 2;

			while (i >= 6) {
				while (j <= 8) {
					checker = new Checker(this.blackChecker.clone(), Logic.BLACK_TEAM);
					currentCell = this.structCells[String(i) + String(j)];
					
					checker.moveTo(currentCell, true);
					
					this.rootContainer.addChild(checker);
					this._arrBlackCheckers.push(checker);
					this._arrAllCheckers.push(checker);

					j += 2;
				}
				
				i--;
				j = (i % 2 == 0)? 2 : 1;
			}
			//----------------------------------
		}

		public function resetCheckers():void {

			while (this._arrAllCheckers.length > 0) {
				this.rootContainer.removeChild(this._arrAllCheckers.pop());
			}
			
			/*for (var i:int = 0; i < this.rootContainer.numChildren; i++) {
				if (this.rootContainer.getChildAt(i) is Checker) {
					this.rootContainer.removeChildAt(i);
				}
			}*/
			
			for each (var cell:Cell in this._structCells) {
				cell.currentChecker = null;
				cell.isOccupied = null;
			}
			
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

		private function uploadResources(resources:Vector.<Resource>, context:Context3D):void {
			for each (var resource:Resource in resources) {
				resource.upload(context);
			}
		}

	}
}