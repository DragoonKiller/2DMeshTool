import { float64, int32, Node2D, print, Variant } from "godot";
import { export_ } from "godot.annotations";

export default class Main extends Node2D {
    
    @export_(Variant.Type.TYPE_INT)
    a : int32 = 12
    
    _ready() {
        print("start")
    }
    
    _process(delta: float64): void {
        print("process")
    }
}
