local config = require 'config.shared'

QBCore = nil

if GetResourceState("qbx_core") == "started" then
    config.framework = "qbox"
    lib.print.debug("Setting sharedConfig as qbox")
    TriggerServerEvent('vib_fabricator:server:setframework', "qbox")
elseif GetResourceState("qb-core") == "started" then
    QBCore = exports['qb-core']:GetCoreObject()
    config.framework = "qbcore"
    lib.print.debug("Setting sharedConfig as qbcore")
    TriggerServerEvent('vib_fabricator:server:setframework', "qbcore")
else
  error("Framework not supported!")
end