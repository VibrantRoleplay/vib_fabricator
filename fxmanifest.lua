fx_version 'cerulean'
game 'gta5'

description 'Vibrant Fabricator'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
    'framework/client.lua'
}

files {
	'config/client.lua',
	'config/shared.lua',
    'config/server.lua',
}

server_scripts {
	'server/*.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'