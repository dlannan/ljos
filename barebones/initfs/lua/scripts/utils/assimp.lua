------------------------------------------------------------------------------------------------------------
-- Asset Import Library Utility functions
--
-- Decription: Converts into internal vbos and fbos 
-- 				Loads Textures and materials
--				Loads meshes into verts buffer

------------------------------------------------------------------------------------------------------------

local assimp = require("ffi/assimp")

require("byt3d/framework/byt3dModel")
require("byt3d/framework/byt3dMesh")

require("byt3d/scripts/utils/xml-reader")

------------------------------------------------------------------------------------------------------------
-- Supported import data types
--        Collada ( *.dae;*.xml )
--        Blender ( *.blend ) 3
--        Biovision BVH ( *.bvh )
--        3D Studio Max 3DS ( *.3ds )
--        3D Studio Max ASE ( *.ase )
--        Wavefront Object ( *.obj )
--        Stanford Polygon Library ( *.ply )
--        AutoCAD DXF ( *.dxf )
--        IFC-STEP, Industry Foundation Classes ( *.ifc )
--        Neutral File Format ( *.nff )
--        Sense8 WorldToolkit ( *.nff )
--        Valve Model ( *.smd,*.vta ) 3
--        Quake I ( *.mdl )
--        Quake II ( *.md2 )
--        Quake III ( *.md3 )
--        Quake 3 BSP ( *.pk3 ) 1
--        RtCW ( *.mdc )
--        Doom 3 ( *.md5mesh;*.md5anim;*.md5camera )
--        DirectX X ( *.x ).
--        Quick3D ( *.q3o;q3s ).
--        Raw Triangles ( .raw ).
--        AC3D ( *.ac ).
--        Stereolithography ( *.stl ).
--        Autodesk DXF ( *.dxf ).
--        Irrlicht Mesh ( *.irrmesh;*.xml ).
--        Irrlicht Scene ( *.irr;*.xml ).
--        Object File Format ( *.off ).
--        Terragen Terrain ( *.ter )
--        3D GameStudio Model ( *.mdl )
--        3D GameStudio Terrain ( *.hmp )
--        Ogre (*.mesh.xml, *.skeleton.xml, *.material)3
--        Milkshape 3D ( *.ms3d )
--        LightWave Model ( *.lwo )
--        LightWave Scene ( *.lws )
--        Modo Model ( *.lxo )
--        CharacterStudio Motion ( *.csm )
--        Stanford Ply ( *.ply )
--        TrueSpace ( *.cob, *.scn )2
--        XGL ( *.xgl, *.zgl )

------------------------------------------------------------------------------------------------------------
-- Make meshes on a Node. This is used to populate node information
--

matpool = {}

function ModelAddMeshes( scene, node, dnode )

    for k=1, dnode.mNumMeshes do

        local mesh = scene.mMeshes[dnode.mMeshes[k-1]]

        -- Get the material index, and build some material info
        local matid = mesh.mMaterialIndex
        local mat = scene.mMaterials[matid]

        local bmesh = byt3dMesh:FromMesh(mesh)
        node:AddBlock(bmesh, ffi.string(dnode.mName.data).."_mesh_"..tostring(k))
    end
end

------------------------------------------------------------------------------------------------------------
-- Make meshes on a Node. This is used to populate node information
--
--
function fmadModelAddMeshes( scene, RL, nodePtr, dnode )

    local headnodePtr = nodePtr
    local node = nodePtr[0]

    for k=1, dnode.mNumMeshes do

        -- Make an Xform parent for each mesh
        if k > 1 then
            OBJECTID = OBJECTID + 1
            local nnode = fObject_Get( RL, fObj.fObject_XForm, NODEID, OBJECTID )
            nnode.Local2World = headnode.Local2World
            headnodePtr = nnode
        end

        local mesh = scene.mMeshes[dnode.mMeshes[k-1]]

        -- Get the material index, and build some material info
        local matid = mesh.mMaterialIndex
        local mat = scene.mMaterials[matid]

        OBJECTID = OBJECTID + 1
        local trimeshPtr = fObject_Get( RL, fObj.fObject_TriMesh, NODEID, OBJECTID )

        local bmeshPtr = ffi.new("fTriMesh_t[1]")
        local bmesh = bmeshPtr[0]

        bmesh.Magic = TRIMESH_MAGIC

        bmesh.IndexCount = mesh.mNumFaces * 3
        bmesh.VertexCount = mesh.mNumVertices
        bmesh.MaterialID = matid

        -- Puts all the indices into a normal lua table - this is safe, and will be our 'source'
        -- to work from and generate the appropriate IBuffer objects
        bmesh.IndexList = ffi.new("Tri_t["..mesh.mNumFaces.."]")
        -- Fill out tri indexes
        for n=0, mesh.mNumFaces-1 do
            local f = mesh.mFaces[n]
            bmesh.IndexList[n].p0 = f.mIndices[0]
            bmesh.IndexList[n].p1 = f.mIndices[1]
            bmesh.IndexList[n].p2 = f.mIndices[2]
        end

        bmesh.VertexList = ffi.new("Vertex_t["..mesh.mNumVertices.."]")
        ftrace("Verts: %d\n", mesh.mNumVertices)

        for i=0, mesh.mNumVertices-1 do
            local v = mesh.mVertices[i]
            bmesh.VertexList[i].Px = v.x
            bmesh.VertexList[i].Py = v.y
            bmesh.VertexList[i].Pz = v.z

            bmesh.VertexList[i].Nx = mesh.mNormals[i].x
            bmesh.VertexList[i].Ny = mesh.mNormals[i].y
            bmesh.VertexList[i].Nz = mesh.mNormals[i].z

            if mesh.mTangents ~= nil then
                bmesh.VertexList[i].Tx = mesh.mTangents[i].x
                bmesh.VertexList[i].Ty = mesh.mTangents[i].y
                bmesh.VertexList[i].Tz = mesh.mTangents[i].z
            end

            if mesh.mBitangents ~= nil then
                bmesh.VertexList[i].Bx = mesh.mBitangents[i].x
                bmesh.VertexList[i].By = mesh.mBitangents[i].y
                bmesh.VertexList[i].Bz = mesh.mBitangents[i].z
            end

            bmesh.VertexList[i].u = mesh.mTextureCoords[0][i].x
            bmesh.VertexList[i].v = mesh.mTextureCoords[0][i].y

            bmesh.VertexList[i].rgba = 0xFFFFFFFF
        end

        trimeshPtr[0].Object = bmeshPtr
        headnode = headnodePtr[0]
        headnode.Object = trimeshPtr
        headnode.RefType = fRz.fRealizeType_TriMesh
    end
end

------------------------------------------------------------------------------------------------------------
-- Make childnodes on a Node. This is used to populate node information
--
--
function ModelAddNodes( scene, node, dnode, accT )

    -- Set rootnode transform
    local m = dnode.mTransformation
    node.transform.m = {
        m.a1, m.b1, m.c1, m.d1,
        m.a2, m.b2, m.c2, m.d2,
        m.a3, m.b3, m.c3, m.d3,
        m.a4, m.b4, m.c4, m.d4
    }

    ModelAddMeshes(scene, node, dnode)

    local tform = ffi.new("aiMatrix4x4", node.transform.m )
    assimp.aiMultiplyMatrix4(tform, accT)
    local ccount = dnode.mNumChildren

    for i=1, ccount do
        local nnode = byt3dNode:New()
        local cnode = dnode.mChildren[i-1]
        node:AddChild( nnode, ffi.string(cnode.mName.data) )
        ModelAddNodes( scene, nnode, cnode, tform )
    end
end

------------------------------------------------------------------------------------------------------------
-- Make childnodes on a Node. This is used to populate node information
--
--
function fmadModelAddNodes( scene, RL, nodePtr, dnode, accT )

    -- Set rootnode transform
    local m = dnode.mTransformation
    local node = nodePtr[0]
    node.Local2World = ffi.new( "fMat44", {
        m.a1, m.b1, m.c1, m.d1,
        m.a2, m.b2, m.c2, m.d2,
        m.a3, m.b3, m.c3, m.d3,
        m.a4, m.b4, m.c4, m.d4
    } )

    fmadModelAddMeshes(scene, RL, nodePtr, dnode)

    local tform = fMat44_Mul(node.Local2World, accT)
    local ccount = dnode.mNumChildren

    for i=1, ccount do
        OBJECTID = OBJECTID + 1
        local nnode = fObject_Get( RL, fObj.fObject_XForm, NODEID, OBJECTID )
        local cnode = dnode.mChildren[i-1]
        fmadModelAddNodes( scene, RL, nnode, cnode, tform )
    end
end

------------------------------------------------------------------------------------------------------------
-- Very basic model loader. 
-- TODO: Needs to be expanded to include pools and model management facitilies.
--       Also need auto texture loading and so on.

-- The loader also writes out our own internal format. This is so we dont need
-- the loader at runtime and release builds only use the internal format.
function LoadModel(filemodel)

    -- Try internal format first - this will be the only available method in release mode
    --local tModel = LoadXml(filemodel..".xml")
    --if tModel ~= nil then return byt3dModel:FromFile(tModel) end

	-- This is what everything will be used for converting to
	local newModel = byt3dModel:New()

	-- Test load some models
	local scene = assimp.aiImportFile(filemodel, bit.bor(assimp.aiProcess_Triangulate, assimp.aiProcess_SortByPType, assimp.aiProcess_FlipUVs  ) )
	local rnode = scene.mRootNode

	print("Scene:", scene,  "  Name:", ffi.string(rnode.mName.data))
    newModel.name = tostring( ffi.string(rnode.mName.data) )

    -- Write out all the materials - use references for rendering and texture gen
    local mcount = scene.mNumMaterials
    for i=1, mcount do
        local newmat = scene.mMaterials[i-1]
        -- Push this material into the current level material pool
    end

	print("NumMeshes:", scene.mNumMeshes)
    local rtform = ffi.new( "aiMatrix4x4", {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1})
    ModelAddNodes( scene, newModel.node, rnode, rtform )

    newModel:BuildBounds()

    SaveXml(filemodel..".xml", newModel, "byt3dModel")
	return newModel
end

------------------------------------------------------------------------------------------------------------
-- Returns a byt3dModel ready to render with the AssImpLib data

function MakeModel()

end

------------------------------------------------------------------------------------------------------------

function fmadLoadModel( RL, filemodel )

    -- Test load some models
    local scene = assimp.aiImportFile(filemodel, bit.bor(assimp.aiProcess_Triangulate, assimp.aiProcess_SortByPType, assimp.aiProcess_FlipUVs  ) )
    local rnode = scene.mRootNode

    print("Scene:", scene,  "  Name:", ffi.string(rnode.mName.data))

    -- fmad data is a little different to normal data layout :) .. it contains
    -- a series of XFroms for structure and TriMeshes for vert data.
    -- Materials are stored globally and Material indexes are used in the TriMeshes to
    -- reference them.

    -- So, working in reverse the Loader creates a global list of materials and puts them
    -- into the Scene global space.

    local name = tostring( ffi.string(rnode.mName.data) )

    -- Write out all the materials - use references for rendering and texture gen
    local mcount = scene.mNumMaterials
    for i=0, mcount-1 do
        local newmat = scene.mMaterials[i]
        -- Push this material into the current level material pool
        local materialPtr = fObject_Get(RL, fObj.fObject_Material, NODEID, i)
        local material = materialPtr[0]

        local diffusePtr = ffi.new("aiColor4D[1]")
        local diffuse = diffusePtr[0]
        assimp.aiGetMaterialColor(newmat, "Diffuse", assimp.aiPTI_Float, 0, diffusePtr)

        local matPtr = ffi.new("fMaterial_t[1]")
        local mat = matPtr[0]
        -- textures
        mat.TextureEnable	= true
        mat.TextureDiffuseObjectID	= 0
        mat.TextureEnvObjectID = 0

        mat.Translucent  = 0.0
        mat.Opacity      = 0.5

        -- shader settings
        mat.Roughness = 0.8
        mat.Attenuation = 0.1
        mat.Ambient = 0.3

        mat.DiffuseR = diffuse.r
        mat.DiffuseG = diffuse.g
        mat.DiffuseB = diffuse.b
        material.Object = matPtr

        table.insert(matpool, materialPtr)
    end

    print("NumMeshes:", scene.mNumMeshes)
    OBJECTID = OBJECTID + 1
    local objectPtr = fObject_Get( RL, fObj.fObject_XForm, NODEID, OBJECTID )
    local object = objectPtr[0]
    object.Local2World = ffi.new( "fMat44", {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1})

    fmadModelAddNodes( scene, RL, objectPtr, rnode, object.Local2World )

    return object
end