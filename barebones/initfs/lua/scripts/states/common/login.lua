------------------------------------------------------------------------------------------------------------
-- State - Login Tester
--
-- Decription: Open a url to a website for FB type login
--				Open a dialog for entering email validation method

------------------------------------------------------------------------------------------------------------

local win = require("scripts/platform/windows")
	
------------------------------------------------------------------------------------------------------------

local Slogin	= NewState()

------------------------------------------------------------------------------------------------------------

local win		= nil

------------------------------------------------------------------------------------------------------------

function Slogin:Begin()

	-- Make a windows little browser client window (this will be different per platform!!!)
	win = CreateWindow(200, 200, 640, 480)

--        WebBrowser browser = new WebBrowser();
--        browser.Size = new Size(500, 500);
--        browser.Dock = DockStyle.Fill;
--
--        if (supportingInfo != null)
--        {
--            try
--            {
--                if (!String.IsNullOrEmpty(supportingInfo.Summary))
--                {
--                    browser.Navigate("about:blank");
--                    if (browser.Document != null)
--                    {
--                        browser.Document.Write(string.Empty);
--                    }
--                    browser.DocumentText = "<html>" + supportingInfo.Summary + "</html>";
--
--                }
--            }
--            catch (Exception ex)
--            {
--                throw ex;
--            }
--        }

end

------------------------------------------------------------------------------------------------------------

function Slogin:Update(mxi, myi, buttons)

	UpdateWindow(win)
end

------------------------------------------------------------------------------------------------------------

function Slogin:Render()

end

------------------------------------------------------------------------------------------------------------

function Slogin:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return Slogin

------------------------------------------------------------------------------------------------------------
