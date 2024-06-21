local sharedConfig = require 'config.shared'

QBCore = nil

if GetResourceState("qbx_core") == "started" then
    sharedConfig.framework = "qbox"
elseif GetResourceState("qb-core") == "started" then
    QBCore = exports['qb-core']:GetCoreObject()
    sharedConfig.framework = "qbox"
else
  error("Framework not supported!")
end