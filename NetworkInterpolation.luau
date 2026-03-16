-- Smooths out other players' movement on the client by lerping their root CFrame each frame.
-- Teleports snap instantly if the distance exceeds a threshold to avoid rubber-banding.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local NetworkInterpolation = {}

export type Config = {
	Enabled?: boolean,
	LerpSpeed?: number,      -- interpolation rate per second (default 35)
	TeleportDist?: number,   -- snap instead of lerp above this distance (default 12)
	RenderPriority?: number, -- render step priority, runs slightly after camera by default
}

local config: Config = {}
local smoothCFs: { [BasePart]: CFrame } = {}
local conn: RBXScriptConnection?

function NetworkInterpolation.init(cfg: Config?)
	config = cfg or {}
	local enabled = config.Enabled ~= false
	local lerpSpeed = config.LerpSpeed or 35
	local teleportDist = config.TeleportDist or 12
	local priority = config.RenderPriority or (Enum.RenderPriority.Camera.Value + 3)

	-- clean up any previous binding before rebinding
	if conn then
		RunService:UnbindFromRenderStep("NetInterp")
		conn = nil
	end
	table.clear(smoothCFs)
	if not enabled then return end

	RunService:BindToRenderStep("NetInterp", priority, function(dt)
		local alpha = math.min(dt * lerpSpeed, 1)

		for _, other in Players:GetPlayers() do
			if other == player then continue end
			local char = other.Character
			if not char or not char.Parent then continue end
			local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then continue end

			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				smoothCFs[root] = nil
				continue
			end

			local current = root.CFrame
			local prev = smoothCFs[root]

			-- first frame we see this player, seed the position
			if not prev then
				smoothCFs[root] = current
				continue
			end

			-- large jump means respawn or teleport, skip the lerp
			local dist = (current.Position - prev.Position).Magnitude
			if dist > teleportDist then
				smoothCFs[root] = current
				continue
			end

			local smoothed = prev:Lerp(current, alpha)
			smoothCFs[root] = smoothed
			root.CFrame = smoothed
		end
	end)

	-- drop stale entries when someone leaves
	Players.PlayerRemoving:Connect(function(p)
		if p == player then return end
		local char = p.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then smoothCFs[root] = nil end
		end
	end)
end

function NetworkInterpolation.stop()
	RunService:UnbindFromRenderStep("NetInterp")
	table.clear(smoothCFs)
end

return NetworkInterpolation
