----------------------------------------------------------------------------------------
--
--                          Locale String Abstraction Layer
--                     Preprocesses XML-encoded locale strings
--
----------------------------------------------------------------------------------------

Locale = {}

--- Preprocesses XML-encoded locale strings by replacing XML tags with appropriate characters
---@param str string - The locale string to preprocess
---@return string - The preprocessed string
function Locale.PreprocessXML(str)
    if not str or str == "" then
        return str
    end

    -- Replace <br> tags with newlines
    str = str:gsub("<[Bb][Rr]>", "\n")

    return str
end

--- Gets a translated string from the localization system and preprocesses it
--- This is a wrapper around Ext.Loca.GetTranslatedString that applies XML preprocessing
---@param handle string - The localization handle
---@param fallback string|nil - Optional fallback text if handle is not found
---@return string - The translated and preprocessed string
function Locale.GetTranslatedString(handle, fallback)
    local translated = Ext.Loca.GetTranslatedString(handle, fallback)
    return Locale.PreprocessXML(translated)
end

return Locale
