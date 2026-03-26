local GLiB = _G.GLiB
if not GLiB then
    return
end

local P = GLiB._p
if not P then
    return
end

P.objData = {
    mailbox = {
        key = "mailbox",
        type = "mailbox",
        kind = "object",
        tags = {
            interact = true,
            mailbox = true,
            stable_name = true,
        },
    },
}

P.objNameToKey = {
    ["mailbox"] = "mailbox",
}