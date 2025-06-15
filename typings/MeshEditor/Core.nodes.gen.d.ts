declare module "godot" {
    interface SceneNodes {
        "MeshEditor/Core.tscn": {
            SpriteDisplay: Sprite2D<{}>,
            MeshEditor: Node2D<
                {
                    Camera2D: Camera2D<{}>,
                }
            >,
        },
    }
}
