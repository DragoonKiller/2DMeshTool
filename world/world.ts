import { float64, Node, Variant } from "godot";
import { export_ } from "godot.annotations";

export default class GameWorld extends Node {
	
	@export_(Variant.Type.TYPE_INT)
	public val = 10
	
	_ready(): void {
		
	}
	
	_process(delta: float64): void {
		
	}
}
