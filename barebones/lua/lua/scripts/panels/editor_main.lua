--
-- Created by David Lannan
-- User: grover
-- Date: 6/03/13
-- Time: 12:07 AM
-- Copyright 2013  Developed for use with the byt3d engine.
--

------------------------------------------------------------------------------------------------------------
-- State - Editor main icon panel
--
-- Decription: Displays the new editor icon dropdown panel.
--			   Icons may be exploders or sliders or buttons.

------------------------------------------------------------------------------------------------------------

local PEditorMain	= NewState()

------------------------------------------------------------------------------------------------------------
-- Load in the new asset management panel - should slide in.

function IconAssets( obj )

    if obj.meta.flags["assets_last"] == "RequestClose" then
        obj.meta.flags["assets"] = "RequestOpen"
        obj.meta.flags["assets_last"] = "RequestOpen"
    else
        obj.meta.flags["assets"] = "RequestClose"
        obj.meta.flags["assets_last"] = "RequestClose"
    end
end

------------------------------------------------------------------------------------------------------------

function IconClose( obj )

    obj.meta.flags["close"] = true
end

------------------------------------------------------------------------------------------------------------


function PEditorMain:Begin()

    -- List of flags used to determine what to do
    self.flags = {}
    self.flags["close"] = false
    self.flags["assets"] = nil
    self.flags["assets_last"] = "RequestClose"

    -- Add all the icons here that we will use.
    self.icons = {}
    self.icons["generic"] = Gcairo:LoadImage("icon_generic", "byt3d/data/icons/generic_64.png")
    self.icons["main"]  = Gcairo:LoadImage("main", "byt3d/data/icons/generic_64.png")
    self.icons["assets"]  = Gcairo:LoadImage("assets", "byt3d/data/icons/generic_obj_folder_64.png")
    self.icons["nodes"]  = Gcairo:LoadImage("nodes", "byt3d/data/icons/generic_obj_list_64.png")
    self.icons["m3"]  = Gcairo:LoadImage("m3", "byt3d/data/icons/generic_obj_attach_64.png")
    self.icons["m4"]  = Gcairo:LoadImage("m4", "byt3d/data/icons/generic_obj_box_64.png")
    self.icons["m5"]  = Gcairo:LoadImage("m5", "byt3d/data/icons/generic_obj_config_64.png")
    self.icons["m6"]  = Gcairo:LoadImage("m6", "byt3d/data/icons/generic_obj_doc_64.png")
    self.icons["close"]  = Gcairo:LoadImage("close", "byt3d/data/icons/generic_obj_close_64.png")
end

------------------------------------------------------------------------------------------------------------

function PEditorMain:Update(mxi, myi, buttons)

    local saved = Gcairo.style.button_color
    local fontsize = 16
    local iconsize = 22
    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local iconlist = Gcairo:List("", 0, 0, 220, fontsize + 10)
    local editor = self

    local line1 = {
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="i_assets", ntype=CAIRO_TYPE.IMAGE, image=self.icons["assets"], size=iconsize, color=tcolor, meta=editor, callback=IconAssets },
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="i_nodes", ntype=CAIRO_TYPE.IMAGE, image=self.icons["nodes"], size=iconsize, color=tcolor },
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="test3", ntype=CAIRO_TYPE.IMAGE, image=self.icons["m3"], size=iconsize, color=tcolor },
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="test4", ntype=CAIRO_TYPE.IMAGE, image=self.icons["m4"], size=iconsize, color=tcolor },
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="test5", ntype=CAIRO_TYPE.IMAGE, image=self.icons["m5"], size=iconsize, color=tcolor },
        { name = " ", ntype=CAIRO_TYPE.TEXT, size=1  },
        { name="test6", ntype=CAIRO_TYPE.IMAGE, image=self.icons["m6"], size=iconsize, color=tcolor },
        { name = "                        ", ntype=CAIRO_TYPE.TEXT, size=8  },
        { name="i_close", ntype=CAIRO_TYPE.IMAGE, image=self.icons["close"], size=iconsize, color=tcolor, meta=editor, callback=IconClose }
    }

    -- A Content window of 'stuff' to show
    local snodes = {}
    snodes[1] =	{ name = " ", ntype=CAIRO_TYPE.TEXT, size=1  }
    snodes[2] =	{ name = "line1", ntype=CAIRO_TYPE.HLINE, size=fontsize + 4 , nodes=line1 }
    iconlist.nodes = snodes

    Gcairo.style.border_width = 0.0
    Gcairo.style.button_color = CAIRO_STYLE.METRO.LBLUE
    Gcairo.style.button_color.a = 1
    Gcairo:Exploder("emain", self.icons["main"], CAIRO_UI.RIGHT, 245, 1, 24, 24, 0, iconlist)

    Gcairo.style.button_color = saved

end

------------------------------------------------------------------------------------------------------------

function PEditorMain:Render()

end

------------------------------------------------------------------------------------------------------------

function PEditorMain:Finish()

end

------------------------------------------------------------------------------------------------------------

return PEditorMain

------------------------------------------------------------------------------------------------------------