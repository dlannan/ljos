--
-- Created by David Lannan - copyright 2013
-- Developed for the Byt3D project. byt3d.codeplex.com
-- User: dlannan
-- Date: 21/04/13
-- Time: 11:59 PM
--

------------------------------------------------------------------------------------------------------------

local Seditor_utils	= {}

------------------------------------------------------------------------------------------------------------

cube_ctr = 0
sphere_ctr = 0

------------------------------------------------------------------------------------------------------------

function Seditor_utils:CreatePhysicsPlane( sz, pos, mass )

    local cubeShape = bullet.plNewBoxShape(sz, 0, sz)

    local user_data = ffi.new("uint32_t[1]")
    local physics = bullet.plCreateRigidBody(user_data, mass, cubeShape)
    local mpos = ffi.new("float[3]", pos[1], pos[2], pos[3])

    bullet.plSetPosition(physics, mpos);
    bullet.plAddRigidBody(gDynamicsWorld, physics);

    return physics
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:CreatePhysicsCube( pos, mass, sz, sh, sl )

    if sh == nil then sh = sz end
    if sl == nil then sl = sz end

    local cubeShape = bullet.plNewBoxShape(sz, sh, sl)

    local user_data = ffi.new("uint32_t[1]")
    local physics = bullet.plCreateRigidBody(user_data, mass, cubeShape)
    local mpos = ffi.new("float[3]", pos[1], pos[2], pos[3])

    bullet.plSetPosition(physics, mpos);
    bullet.plAddRigidBody(gDynamicsWorld, physics);

    return physics
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:CreatePhysicsSphere( sz, pos, mass )
    local cubeShape = bullet.plNewSphereShape(sz)

    local user_data = ffi.new("uint32_t[1]")
    local physics = bullet.plCreateRigidBody(user_data, mass, cubeShape)
    local mpos = ffi.new("float[3]", pos[1], pos[2], pos[3])

    bullet.plSetPosition(physics, mpos);
    bullet.plAddRigidBody(gDynamicsWorld, physics);

    return physics
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:CreatePhysicsFromModel(tmodel, mass)

    local cubeShape = bullet.plNewConvexHullShape()
    -- Get model verts
    local meshes = tmodel:GetMeshes("byt3dMesh")
    for l, m in ipairs(meshes) do
        local buffers = m.ibuffers
        for k,b in ipairs(buffers) do
            local verts     = b.vertBuffer
            local inds      = b.indexBuffer
            local sz = ffi.sizeof(inds) / 2
            for i = 0, sz-1 do
                local v = inds[i]
                bullet.plAddVertex(cubeShape, verts[v * 3], verts[v * 3 + 1], verts[v * 3 + 2])
            end
        end
    end

    local user_data = ffi.new("uint32_t[1]")
    tmodel.physics = bullet.plCreateRigidBody(user_data, mass, cubeShape)
    local mpos = ffi.new("float[3]", pos[1], pos[2], pos[3])

    bullet.plSetPosition(tmodel.physics, mpos);
    bullet.plAddRigidBody(gDynamicsWorld, tmodel.physics);
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:AddTestCanon(level, pos, col)

    -- The mesh should convert the model to binary - to be used afterwards
    local tmodel = LoadModel("byt3d/editor/cache/meshes/Canon.dae", 1)
    tmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)
    tmodel.node.transform:Position(pos[1], pos[2], pos[3])

    local newtex = byt3dTexture:New()
    newtex:NewColorImage( col )

    local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    newshader.name = "Shader_Default"

    tmodel:SetMeshProperty("shader", newshader)
    tmodel:SetSamplerTex(newtex, "s_tex0")

    -- Generate an icon - named after the converted data set
    level.nodes["root"]:AddChild(tmodel, "Model_"..tmodel.name)
    return tmodel
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:AddBlock( level, mass, pos, col, sz, sh, sl )

    if sh == nil then sh = sz end
    if sl == nil then sl = sz end

    local newmodel = byt3dModel:New()
    local newshader = byt3dShader:NewProgram(grid_shader_vert, colour_shader_frag)
    local newtex = byt3dTexture:New()

    newtex:NewColorImage( col )
    newmodel:GenerateBlock(sz, sh, sl, 1)
    newmodel:SetMeshProperty("alpha", 1.0)
    newmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)
    newmodel:SetMeshProperty("shader", newshader)

    newmodel:SetSamplerTex(newtex, "s_tex0")
    newmodel.node.transform:RotationHPR(0.0, 0.0, 0.0)
    newmodel.node.transform:Position(pos[1], pos[2], pos[3])

    newmodel.physics = self:CreatePhysicsCube( pos, mass, sz, sh, sl )

    level.nodes["root"]:AddChild(newmodel, "Cube"..string.format("%03d", cube_ctr))
    cube_ctr = cube_ctr + 1
    return newmodel
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:AddCube( level, sz, pos, col, sh, sl )

    if sh == nil then sh = sz end
    if sl == nil then sl = sz end

    local newmodel = byt3dModel:New()
    local newshader = byt3dShader:NewProgram(grid_shader_vert, colour_shader_frag)
    local newtex = byt3dTexture:New()

    newtex:NewColorImage( col )
    newmodel:GenerateCube(sz, 1, sh, sl)
    newmodel:SetMeshProperty("alpha", 1.0)
    newmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)
    newmodel:SetMeshProperty("shader", newshader)

    newmodel:SetSamplerTex(newtex, "s_tex0")
    newmodel.node.transform:RotationHPR(0.0, 0.0, 0.0)
    newmodel.node.transform:Position(pos[1], pos[2], pos[3])

    newmodel.physics = self:CreatePhysicsCube( pos, 1.0, sz )

    level.nodes["root"]:AddChild(newmodel, "Cube"..string.format("%03d", cube_ctr))
    cube_ctr = cube_ctr + 1
    return newmodel
end

------------------------------------------------------------------------------------------------------------

function Seditor_utils:AddSphere( level, sz, pos, col, mass )

    if mass == nil then mass = 1.0 end
    local newmodel = byt3dModel:New()
    local newshader = byt3dShader:NewProgram(grid_shader_vert, colour_shader_frag)
    local newtex = byt3dTexture:New()

    newtex:NewColorImage( col )
    newmodel:GenerateSphere(sz, 6)
    newmodel:SetMeshProperty("alpha", 1.0)
    newmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)
    newmodel:SetMeshProperty("shader", newshader)

    newmodel:SetSamplerTex(newtex, "s_tex0")
    newmodel.node.transform:RotationHPR(0.0, 0.0, 0.0)
    newmodel.node.transform:Position(pos[1], pos[2], pos[3])

    newmodel.physics = self:CreatePhysicsSphere(sz, pos, mass)

    level.nodes["root"]:AddChild(newmodel, "Sphere"..string.format("%03d", sphere_ctr))
    sphere_ctr = sphere_ctr + 1
    return newmodel
end

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

return Seditor_utils

------------------------------------------------------------------------------------------------------------
