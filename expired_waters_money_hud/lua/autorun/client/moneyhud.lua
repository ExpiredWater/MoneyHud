-- moneyhud V2
--
-- Coded By 
-- ____ _  _ ___  _ ____ ____ ___     _ _ _ ____ ___ ____ ____ 
-- |___  \/  |__] | |__/ |___ |  \    | | | |__|  |  |___ |__/ 
-- |___ _/\_ |    | |  \ |___ |__/    |_|_| |  |  |  |___ |  \ 
-- (https://steamcommunity.com/id/Expired_Water/)
-- (https://www.gmodstore.com/users/Expired_Water)
--
--
-- Change Log
-- V1 Initial Release
-- V2 Added darkrp_cheque to moneyhud
local radius = 500

local lineHeight = 300
local squareHeight = 15

local money = {}
local money_cheque = {}

print( "====================" )
print( "Loaded Money Hud V2.0" )
print( "By Expired Water" )
print( "====================" )

CreateConVar( "moneyhud_enabled", 1, FCVAR_ARCHIVE, "Enables money hud new UI" )

local fontHeight = 100
surface.CreateFont( "MoneyhudCashFont", {
	font = "Arial",
	extended = false,
	size = fontHeight,
	weight = 1000,
} )

--Finds all of the money in the area around the player
local function FindMoney()
	if GetConVar("moneyhud_enabled"):GetInt() == 0 then return end

	if ( not IsValid( LocalPlayer() ) ) then return end
	local found = ents.FindInSphere( LocalPlayer():GetPos(), radius )
	money = {}
	for I = 1, #found do
		if found[I]:GetClass() == "spawned_money" then
			table.insert( money, found[I] )
		elseif found[I]:GetClass() == "darkrp_cheque" then
			table.insert( money, found[I] )
		end
	end
end

--Start our own recurring timer to find money in a radius at a more reasonable rate than every frame.
hook.Add( "Initialize", "MoneyhudInit", function()

	timer.Create( "MoneyhudTimer", 0.1, 0,
		function()
			FindMoney()
		end
	)
end)

hook.Add( "PostDrawTranslucentRenderables", "MoneyhudDrawing", function()
	if GetConVar("moneyhud_enabled"):GetInt() == 0 then return end
	--FindMoney()
	for I = 1, #money do
		local ent = money[I]
			if ( not IsValid( ent ) ) then return end
			local pos = ent:GetPos() + ent:OBBCenter() + Vector( 0, 0, ent:OBBMaxs().z )
			-- Trig garbage to point 2d3d at player
		dY = pos.y - LocalPlayer():GetPos().y
		dX = pos.x - LocalPlayer():GetPos().x
			local ang = Angle( 0, math.atan2(dY, dX) * 180 / math.pi, 0 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Up(), -90 )
			local scale = 0.1
			cam.Start3D2D( pos, ang, scale )
				surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
					--Drawing base square
			local x, y, w, h = -squareHeight/2, squareHeight, squareHeight, squareHeight
			surface.DrawRect( x, -y, w, h )
					--Drawing line
			local lineWidth = 4
			x, y, w, h = -lineWidth/2, squareHeight, lineWidth, -lineHeight - 5
			surface.DrawRect( x, -y, w, h )
					str = DarkRP.formatMoney(ent:Getamount())
					--Drawing background moneyhud signs
			surface.SetFont( "MoneyhudCashFont" )
			x, y = -( surface.GetTextSize( str ) ) / 2 - fontHeight / 30 , lineHeight + squareHeight + fontHeight + 15 - fontHeight / 20
			surface.SetTextPos( x , -y )
			surface.SetTextColor( Color( 10, 10, 10 ) )
			surface.DrawText( str )
							--Drawing moneyhud signs
			surface.SetFont( "MoneyhudCashFont" )
			x, y = -( surface.GetTextSize( str ) ) / 2, lineHeight + squareHeight + fontHeight + 15
			surface.SetTextPos( x , -y )
			surface.SetTextColor( Color( 100, 255, 100 ) )
			surface.DrawText( str )
				cam.End3D2D()
	end
end)