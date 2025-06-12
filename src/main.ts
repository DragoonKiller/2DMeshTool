import { float64, int32, Node2D, print, Variant } from "godot";
import { export_ } from "godot.annotations";
import World from "../world/world";

export default class Main extends Node2D {
	
	@export_(Variant.Type.TYPE_INT)
	a : int32 = 12
	
	_ready() {
		print("start")
	}
	
	_process(delta: float64): void {
		var world = <World>this.get_tree().root.find_child("World", false, false)
		print(world.val)
	}
}
