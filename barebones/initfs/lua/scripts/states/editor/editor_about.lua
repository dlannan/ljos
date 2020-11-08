--
-- Created by David Lannan
-- User: grover
-- Date: 20/04/13
-- Time: 11:33 PM
-- Copyright 2013  Developed for use with the byt3d engine.
--


------------------------------------------------------------------------------------------------------------

local Seditor_about	= NewState()

------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------

function Seditor_about:Begin()

    self.width 		= Gcairo.WIDTH
    self.height 	= Gcairo.HEIGHT

    self.image2 	= Gcairo:LoadImage("icon_close", "byt3d/data/icons/generic_obj_close_64.png")
    self.image2.scalex 		= 0.35
    self.image2.scaley 		= 0.35

    -- Package logos...
    self.logo1      = Gcairo:LoadImage("logo_lua", "byt3d/data/images/logos/lua_600.png")
    self.logo2      = Gcairo:LoadImage("logo_luajit", "byt3d/data/images/logos/luaJIT.png")
    self.logo3      = Gcairo:LoadImage("logo_assimplib", "byt3d/data/images/logos/assimplibrary.png")
    self.logo4      = Gcairo:LoadImage("logo_cairo", "byt3d/data/images/logos/cairographics.png")
    self.logo5      = Gcairo:LoadImage("logo_sdl", "byt3d/data/images/logos/SDL.png")
    self.logo6      = Gcairo:LoadImage("logo_egl", "byt3d/data/images/logos/EGL_OpenGL.png")
    self.logo7      = Gcairo:LoadImage("logo_opengles", "byt3d/data/images/logos/OpenGL_ES.png")
    self.logo8      = Gcairo:LoadImage("logo_bullet", "byt3d/data/images/logos/bullet.png")

end

------------------------------------------------------------------------------------------------------------

function Seditor_about:Update(mxi, myi, buttons)

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    Gcairo.style.button_border_color  = { r=1.0, b=1.0, g=1.0, a=1.0 }
    Gcairo.style.border_width = 0.0
    Gcairo:Begin()

    -- Gcairo:RenderImage(bgimage, 0, 0, 0.0)

    local saved = Gcairo.style.button_color
    Gcairo.style.button_color = { r=0.0, b=0.1, g=0.0, a=1 }
    Gcairo:RenderBox(0, 0, self.width, self.height, 0)
    Gcairo.style.button_color = saved


    Gcairo:RenderText("byt3d", 120, 70, 30, tcolor )
    Gcairo:RenderText(BYT3D_VERSION, 120, 100, 11, tcolor)
    Gcairo:RenderText("www.gagagames.com", self.width - 250, self.height - 30, 20, tcolor )

    Gcairo:RenderText("byt3d exists thanks to these great packages...", 120, 140, 20, tcolor )
    Gcairo.style.button_color = { r=1, b=1, g=1, a=1 }
    Gcairo:RenderBox(120, 160, self.width-250, 350, 0)
    local slidewidth = self.width-250
    Gcairo:RenderMultiSlideImage("About_Slider", { self.logo1, self.logo2, self.logo3, self.logo4,
                 self.logo5, self.logo6, self.logo7, self.logo8 }, 120, 160, slidewidth, 6.0, 0.7, nil)

    Gcairo:ButtonImage("icon_close", self.image2, self.width - 32, 8, ExitConfigManager )
    --Dont have to render a button to have an active element attached to it!
    local button = Gcairo:Button( "httplink", self.width-250, self.height-50, 200, 20, 0, 0, LaunchLink)
    --Gcairo:RenderButton(button, 0.0)

    Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------

function Seditor_about:Render()

    Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------

function Seditor_about:Finish()

end

------------------------------------------------------------------------------------------------------------

return Seditor_about

------------------------------------------------------------------------------------------------------------
