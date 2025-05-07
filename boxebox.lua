-- MIT License

-- Copyright (c) 2025 Jonald Duck

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

addon.name      = "boxebox";
addon.author    = "JonaldDuck";
addon.version   = "1.0.0";
addon.desc      = "Track the contents of your ebox in a file";
addon.link      = "https://github.com/JonaldDuck/boxebox";

require("common");

local imgui = require('imgui');
local json = require('json');

local eboxFileName = "ebox.json";

local path = ('%s\\config\\addons\\%s'):fmt(AshitaCore:GetInstallPath(), 'boxebox');

local boxDict = {};


print("-- boxebox --")

-- example ebox moessage
-- Ephemeral Box : I have 2 Ifritite. (Goldsmithing    Rock)

ashita.events.register('text_in', 'text_in_cb', function (e)
    --really gross I should really brush up on regex and not do hard coded substring indecies lol
    if e ~= nil and e.message ~= nil then
        if string.find(e.message, "Ephemeral Box : I have") then
            --update boxDicts with parsed item and how many we have of it

            --strip out the parenthesis at the end
            local itemString = string.gsub(e.message, "%([^()]*%)", "")
            --strip out the characters before the item of ebox message and the period at the end
            itemString = string.sub(itemString, 23, string.len(itemString)-3)

            --strip out the number of items we have of it
            local amount = itemString:match("(%d+) (.+)")

            local itemName = string.sub(itemString, string.len(amount)+2, string.len(itemString))
            itemName = itemName:match("^%s*(.-)%s*$")

            boxDict[itemName] = amount
            saveBoxData()
        end
        if string.find(e.message, "You store") then
            --strip out you store
            local itemString = string.sub(e.message, 11, string.len(e.message))

            local amount = itemString:match("%(([^%)]+)%)")
            amount = amount:match("(%d+)")

            local itemName = itemString:match("^([^x]+)x%d+")
            itemName = itemName:match("^%s*(.-)%s*$")

            boxDict[itemName] = amount
            saveBoxData()
        end
    end
    
end);

function loadBoxData()
    if ashita.fs.exists(path) then
        print("Loading ebox data from file.")
        local file, errorString = io.open(path .. "\\" .. eboxFileName, "r");
        if file ~= nil then
            boxDict = json.decode(file:read("*a"));
            if boxDict == nil then
                boxDict = {}
            end          
            print("Ebox data found and loaded.  Access the file in the config/addons/boxebox folder to see what is there.")
            io.close(file);
        end
        
        if boxDict == nil then
            boxDict = {}
            print("No box data found, a new file will be created to track the box.");
        end
        
    end
end

loadBoxData()

function saveBoxData()
    if not ashita.fs.exists(path) then
        ashita.fs.create_directory(path);
    end
    local file, errorString = io.open( path .. "\\" .. eboxFileName, "w+" );

    if file ~=nil then
        file:write(json.encode(boxDict))
    end
    io.close(file);
end

ashita.events.register("command", "command_callback1", function (e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= "/boxebox") then
        return;
    else
        e.blocked = true;
        if (args[2] == "reset") then
            print("To reset your box contents, delete the ebox.json file in the config/addons/boxebox folder.");
            print("Note that if you have logged into another character, this will not track the differences between them or if you've played on multiple.");
        end
    end
end);
