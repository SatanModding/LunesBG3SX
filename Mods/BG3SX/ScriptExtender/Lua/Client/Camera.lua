Camera = {}

function Camera:SnapCameraTo(entity)
    local position = entity.Transform.Transform.Translate

    local camera = Ext.Entity.GetAllEntitiesWithComponent("GameCameraBehavior")[1]

    camera.GameCameraBehavior.Targets = {}
    camera.GameCameraBehavior.PlayerInControl = true
    camera.GameCameraBehavior.TrackTarget = nil

    camera.GameCameraBehavior.TargetDestination = position
end
