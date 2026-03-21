local ADDON_NAME, ns = ...

ns.Data = ns.Data or {}

ns.RegisterDataCategory = ns.RegisterDataCategory or function(category, data)
    ns.Data[category] = data
end