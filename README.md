# Roblox Network Interpolation

Client-side CFrame interpolation for other players' characters. Smooths network jitter by lerping between received positions.

## Installation

Copy `NetworkInterpolation.luau` into your project (e.g. `ReplicatedStorage` or `StarterPlayerScripts`).

## Usage

```lua
local NetworkInterpolation = require(path.to.NetworkInterpolation)

NetworkInterpolation.init({
    Enabled = true,
    LerpSpeed = 35,
    TeleportDist = 12,
    RenderPriority = Enum.RenderPriority.Camera.Value + 3,
})
```

### Config

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Enabled | boolean | true | Toggle interpolation |
| LerpSpeed | number | 35 | Lerp alpha per second |
| TeleportDist | number | 12 | Distance threshold; beyond this, snap instead of lerp |
| RenderPriority | number | Camera+3 | Render step priority |

### Stop

```lua
NetworkInterpolation.stop()
```

## License

MIT
