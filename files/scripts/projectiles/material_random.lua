MaterialOptions =
{
	{ probability = 1.0000, "acid"},
	{ probability = 1.0000, "blood"},
	{ probability = 1.0000, "oil"},
	{ probability = 1.0000, "water"},
	{ probability = 1.0000, "blood"},
	{ probability = 0.6000, "silver"},
	{ probability = 0.4000, "magic_liquid_berserk"},
	{ probability = 0.4000, "magic_liquid_unstable_teleportation"},
	{ probability = 0.4000, "snow"},
	{ probability = 0.3000, "magic_liquid_polymorph"},
	{ probability = 0.3000, "magic_liquid_random_polymorph"},
	{ probability = 0.2000, "gunpowder_unstable_big"},
	{ probability = 0.2000, "purifying_powder"},
	{ probability = 0.1000, "urine"},
	{ probability = 0.1000, "pea_soup"},
	{ probability = 0.1000, "void_liquid"},
	{ probability = 0.1000, "magic_liquid_hp_regeneration"},
	{ probability = 0.1000, "cement"},
	{ probability = 0.0500, "gold"},
	{ probability = 0.0500, "poo"},
	{ probability = 0.0100, "midas_precursor"},
	{ probability = 0.0100, "magic_liquid_hp_regeneration_unstable"},
    -- APPEND MATERIALS HERE
}

do_mod_appends("mods/copis_things/files/scripts/projectiles/material_random.lua") --run appends early before code is executed but after table is created

local function RandomFromTable(t)
	local total_weight = 0
	for _, entry in ipairs(t) do
		total_weight = total_weight + entry.probability
	end

	local rnd = Randomf(0, total_weight)
	for _, entry in ipairs(t) do
		if rnd <= entry.probability then
			return entry
		else rnd = rnd - entry.probability end
	end
	return t[#t]
end

local entity = GetUpdatedEntityID();

SetRandomSeed(9123,58925+GameGetFrameNum() )
local mat = tostring(RandomFromTable(MaterialOptions)[1])
local children = EntityGetAllChildren( entity ) or {};

for _,particle_emitter in pairs( EntityGetComponent( entity, "ParticleEmitterComponent" ) or {} ) do
    ComponentSetValue2(particle_emitter, "emitted_material_name", mat)
end
for _,material_spawner in pairs( EntityGetComponent( entity, "MaterialSeaSpawnerComponent" ) or {} ) do
    ComponentSetValue2(material_spawner, "material", CellFactory_GetType(mat))
end
for _,projectile in pairs( EntityGetComponent( entity, "ProjectileComponent" ) or {} ) do
    ComponentSetValue2(projectile, "on_death_emit_particle_type", mat)
    ComponentObjectSetValue2(projectile, "config_explosion", "create_cell_material", mat)
end
for _,magic_convert_material in pairs( EntityGetComponent( entity, "MagicConvertMaterialComponent" ) or {} ) do
    ComponentSetValue2(magic_convert_material, "to_material", CellFactory_GetType(mat))
end

for _,child in pairs(children) do
    for _,particle_emitter in pairs( EntityGetComponent( child, "ParticleEmitterComponent" ) or {} ) do
        ComponentSetValue2(particle_emitter, "emitted_material_name", mat)
    end
end

return --return here to avoid running appends a second time