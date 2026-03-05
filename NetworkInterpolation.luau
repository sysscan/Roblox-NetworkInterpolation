local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local NetworkInterpolation = {}

export type Config = {
	Enabled?: boolean,
	LerpSpeed?: number,
	TeleportDist?: number,
	RenderPriority?: number,
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
			if not prev then
				smoothCFs[root] = current
				continue
			end

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
