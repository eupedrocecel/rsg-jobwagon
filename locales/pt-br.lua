local Translations = {
error = {
    no_wagon_setup = 'nenhum vagão configurado',
    already_have_wagon = 'você já possui um vagão de empresa',
    not_the_boss = 'você não é o chefe',
},
success = {
    wagon_stored = 'vagão de empresa armazenado',
    wagon_setup_successfully = 'configurou com sucesso o seu vagão de empresa',
},
primary = {
    wagon_out = 'vagão de empresa retirado',
    wagon_already_out = 'seu vagão de empresa já está fora',
},
menu = {
    wagon_menu = 'Menu do Vagão',
    wagon_setup = 'Configurar Vagão (Chefe)',
    wagon_get = 'Pegar Vagão',
    wagon_store = 'Armazenar Vagão',
    close_menu = '>> Fechar Menu <<',
},
}

if GetConvar('rsg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
