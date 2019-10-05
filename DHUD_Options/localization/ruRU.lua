--if true then return end
if GetLocale() ~= "ruRU" then return end
DHUDOptionsLocalization = DHUDOptionsLocalization or { };
local L = DHUDOptionsLocalization;
-- buttons text
L["BUTTON_RESET"] = "Сбросить";
L["BUTTON_PROFILES"] = "Профили";
L["BUTTON_YES"] = "Да";
L["BUTTON_NO"] = "Нет";
-- popup texts
L["POPUP_RESET"] = "Вы действительно хотите\nсбросить настройки?";
-- help texts
L["HELP_TIMERS"] = "Введите имена таймеров,\nразделяя запятой\nили переносом строки.\nДля предметов\nиспользуйте название\nпредмета или тег\n<slot:id>.\n" ..
	"|cff88ff88Номера слотов:|r\n" ..
	"Голова = 1\nШея = 2\nПлечи = 3\nРубашка = 4\nНагрудник = 5\nПояс = 6\nПоножи = 7\nОбувь = 8\nНаручи = 9\nПерчатки = 10\nКольца = 11,12\nАксессуары = 13,14\nПлащ = 15\nОружие = 16,17,18\nГербовая накидка = 19";
L["HELP_UNITTEXTS"] = "Вы можете указать теги\nдля изменения выводимой\nинформации.\nКаждый тип данных\nимеет свой список тегов.\nПараметры тегов читаются\nкак LUA код.\n" ..
	"|cff88ff88Доступные Теги:|r\n" ..
	"\n|cffff0000Все типы данных:|r\n" ..
	"<color(\"ffffff\")>\n</color>\n";
L["HELP_UNITTEXTS_TYPE"] = {
	["health"] = 
		"\n|cffff0000Данные о здоровье:|r\n" ..
		"<amount>\n<amount_extra>\n<amount_habsorb>\n<amount_hincome>\n<amount_max>\n<amount_percent>\nарг1 = префикс\nарг2 = точность\n\n" ..
		"<color_amount>\n<color_amount_extra>\n<color_amount_habsorb>\n<color_amount_hincome>\n",
	["power"] = 
		"\n|cffff0000Данные о ресурсах:|r\n" ..
		"<amount>\n<amount_max>\n<amount_percent>\nарг1 = префикс\nарг2 = точность\n\n" ..
		"<color_amount>\n",
	["unitInfo"] = 
		"\n|cffff0000Данные о цели:|r\n" ..
		"<level>\n<elite>\n<name>\n<class>\n<pvp>\n<color_level>\n<color_reaction>\n<color_class>\n\n" ..
		"<guild>\nарг1 = префикс\nарг2 = постфикс\n",
	["cast"] = 
		"\n|cffff0000Данные о заклинании:|r\n" ..
		"<time>\n<time_remain>\n<time_total>\n\n" ..
		"<delay>\nарг1 = префикс закл.\nарг2 = преф. поддерж. з.\n\n" ..
		"<spellname>\nарг1 = Текст прерывания\n",
};
L["HELP_SERVICE_LUASTARTUP"] = "Укажите код для\nисполнения при\nзапуске\n\nПример можно найти в\nфайле DHUD_Settings.lua\nпод ключом\n\"luaStartUpCodes\"\nЛибо написав в чате:\n/dhud debug set_exlua";
-- tabs
L["TAB_GENERAL"] = "Общие";
L["TAB_LAYOUTS"] = "Разметка";
L["TAB_TIMERS"] = "Таймеры";
L["TAB_COLORS"] = "Цвета";
L["TAB_UNITTEXTS"] = "Тексты";
L["TAB_OFFSETS"] = "Сдвиг";
L["TAB_SERVICE"] = "Служебные";
-- general blizzard
L["HEADER_BLIZZARD"] = "Стандартные панели:";

L["SETTING_BLIZZARD_PLAYER"] = "Показ. панель игрока";
L["SETTING_BLIZZARD_PLAYER_TOOLTIP"] = "Показать стандартную панель игрока";

L["SETTING_BLIZZARD_TARGET"] = "Показ. панель цели";
L["SETTING_BLIZZARD_TARGET_TOOLTIP"] = "Показать стандартную панель цели";

L["SETTING_BLIZZARD_CASTBAR"] = "Показ. панель закл.";
L["SETTING_BLIZZARD_CASTBAR_TOOLTIP"] = "Показать стандартную панель произнесения заклинаний";

L["SETTING_BLIZZARD_SPELLACTIVATION_ALPHA"] = "Непрозр. актив. закл.";
L["SETTING_BLIZZARD_SPELLACTIVATION_ALPHA_TOOLTIP"] = "Изменить непрозрачность стандартной панели активации заклинаний";

L["SETTING_BLIZZARD_SPELLACTIVATION_SCALE"] = "Масштаб актив. закл.";
L["SETTING_BLIZZARD_SPELLACTIVATION_SCALE_TOOLTIP"] = "Изменить масштаб стандартной панели активации заклинаний";

-- general scale
L["HEADER_SCALE"] = "Масштаб:";

L["SETTING_SCALE_MAIN"] = "Панель целиком";
L["SETTING_SCALE_MAIN_TOOLTIP"] = "Изменить масштаб панели целиком";

L["SETTING_SCALE_SPELL_CIRCLES"] = "Круглые рамки закл.";
L["SETTING_SCALE_SPELL_CIRCLES_TOOLTIP"] = "Изменить размер круглых рамок с заклинаниями";

L["SETTING_SCALE_SPELL_RECTANGLES"] = "Прям. рамки закл.";
L["SETTING_SCALE_SPELL_RECTANGLES_TOOLTIP"] = "Изменить размер прямоугольных рамок с заклинаниями";

L["SETTING_SCALE_RESOURCES"] = "Рамки ресурсов";
L["SETTING_SCALE_RESOURCES_TOOLTIP"] = "Изменить размер рамок ресурсов, например рамок комбо-очков или рун";

-- general alpha
L["HEADER_ALPHA"] = "Непрозрачность:";

L["SETTING_ALPHA_COMBAT"] = "Непроз. в бою";
L["SETTING_ALPHA_COMBAT_TOOLTIP"] = "Изменить непрозрачность панели во время боя";

L["SETTING_ALPHA_HASTARGET"] = "Непроз. с целью";
L["SETTING_ALPHA_HASTARGET_TOOLTIP"] = "Изменить непрозрачность панели вне боя с выбранной целью";

L["SETTING_ALPHA_REGEN"] = "Непроз. реген.";
L["SETTING_ALPHA_REGEN_TOOLTIP"] = "Изменить непрозрачность панели вне боя во время регенерации ресурсов";

L["SETTING_ALPHA_OUTOFCOMBAT"] = "Непроз. вне боя";
L["SETTING_ALPHA_OUTOFCOMBAT_TOOLTIP"] = "Изменить непрозрачность панели вне боя без выбранной цели и отсутствием регенерации";

-- general font size
L["HEADER_FONTSIZE"] = "Размеры шрифта:";

L["SETTING_FONTSIZE_LEFTBIGBAR1"] = "Бол. лев. внутр. панель";
L["SETTING_FONTSIZE_LEFTBIGBAR1_TOOLTIP"] = "Изменить размер шрифта для большой левой внутренней панели";

L["SETTING_FONTSIZE_LEFTBIGBAR2"] = "Бол. лев. внеш. панель";
L["SETTING_FONTSIZE_LEFTBIGBAR2_TOOLTIP"] = "Изменить размер шрифта для большой левой внешней панели";

L["SETTING_FONTSIZE_LEFTSMALLBAR1"] = "Мал. лев. внутр. панель";
L["SETTING_FONTSIZE_LEFTSMALLBAR1_TOOLTIP"] = "Изменить размер шрифта для малой левой внутренней панели";

L["SETTING_FONTSIZE_LEFTSMALLBAR2"] = "Мал. лев. внеш. панель";
L["SETTING_FONTSIZE_LEFTSMALLBAR2_TOOLTIP"] = "Изменить размер шрифта для малой левой внешней панели";

L["SETTING_FONTSIZE_RIGHTBIGBAR1"] = "Бол. прав. внутр. панель";
L["SETTING_FONTSIZE_RIGHTBIGBAR1_TOOLTIP"] = "Изменить размер шрифта для большой правой внутренней панели";

L["SETTING_FONTSIZE_RIGHTBIGBAR2"] = "Бол. прав. внеш. панель";
L["SETTING_FONTSIZE_RIGHTBIGBAR2_TOOLTIP"] = "Изменить размер шрифта для большой правой внешней панели";

L["SETTING_FONTSIZE_RIGHTSMALLBAR1"] = "Мал. прав. внутр. панель";
L["SETTING_FONTSIZE_RIGHTSMALLBAR1_TOOLTIP"] = "Изменить размер шрифта для малой правой внутренней панели";

L["SETTING_FONTSIZE_RIGHTSMALLBAR2"] = "Мал. прав. внеш. панель";
L["SETTING_FONTSIZE_RIGHTSMALLBAR2_TOOLTIP"] = "Изменить размер шрифта для малой правой внешней панели";

L["SETTING_FONTSIZE_TARGETINFO1"] = "Верх. инф. о цели";
L["SETTING_FONTSIZE_TARGETINFO1_TOOLTIP"] = "Изменить размер шрифта для верхней панели информации о цели";

L["SETTING_FONTSIZE_TARGETINFO2"] = "Ниж. инф. о цели";
L["SETTING_FONTSIZE_TARGETINFO2_TOOLTIP"] = "Изменить размер шрифта для нижней панели информации о цели";

L["SETTING_FONTSIZE_SPELLCIRCLESTIME"] = "Время на круг. рамках";
L["SETTING_FONTSIZE_SPELLCIRCLESTIME_TOOLTIP"] = "Изменить размер шрифта для времени на круглых рамках заклинаний";

L["SETTING_FONTSIZE_SPELLCIRCLESSTACKS"] = "Кол-во на круг. рамках";
L["SETTING_FONTSIZE_SPELLCIRCLESSTACKS_TOOLTIP"] = "Изменить размер шрифта для количества на круглых рамках заклинаний";

L["SETTING_FONTSIZE_SPELLRECTANGLESTIME"] = "Время на прям. рамках";
L["SETTING_FONTSIZE_SPELLRECTANGLESTIME_TOOLTIP"] = "Изменить размер шрифта для времени на прямоугольных рамках заклинаний";

L["SETTING_FONTSIZE_SPELLRECTANGLESSTACKS"] = "Кол-во на прям. рамках";
L["SETTING_FONTSIZE_SPELLRECTANGLESSTACKS_TOOLTIP"] = "Изменить размер шрифта для количества на прямоугольных рамках заклинаний";

L["SETTING_FONTSIZE_RESOURCETIME"] = "Время ресурсов";
L["SETTING_FONTSIZE_RESOURCETIME_TOOLTIP"] = "Изменить размер шрифта для времени на рамках ресурсов, напр. Рун Рыцарей Смерти";

L["SETTING_FONTSIZE_CASTBARSTIME"] = "Время произн. закл.";
L["SETTING_FONTSIZE_CASTBARSTIME_TOOLTIP"] = "Изменить размер шрифта для времени на рамке произнесения заклинания";

L["SETTING_FONTSIZE_CASTBARSDELAY"] = "Задержка произ. закл.";
L["SETTING_FONTSIZE_CASTBARSDELAY_TOOLTIP"] = "Изменить размер шрифта для задержки на рамке произнесения заклинания";

L["SETTING_FONTSIZE_CASTBARSSPELL"] = "Название закл.";
L["SETTING_FONTSIZE_CASTBARSSPELL_TOOLTIP"] = "Изменить размер шрифта для названия заклинания на рамке произнесения заклинания";

-- general font outlines
L["HEADER_FONTOUTLINE"] = "Контур шрифта:";

L["SETTING_FONTOUTLINE_LEFTBIGBAR1"] = "Бол. лев. внутр. панель";
L["SETTING_FONTOUTLINE_LEFTBIGBAR1_TOOLTIP"] = "Изменить контур шрифта для большой левой внутренней панели";

L["SETTING_FONTOUTLINE_LEFTBIGBAR2"] = "Бол. лев. внеш. панель";
L["SETTING_FONTOUTLINE_LEFTBIGBAR2_TOOLTIP"] = "Изменить контур шрифта для большой левой внешней панели";

L["SETTING_FONTOUTLINE_LEFTSMALLBAR1"] = "Мал. лев. внутр. панель";
L["SETTING_FONTOUTLINE_LEFTSMALLBAR1_TOOLTIP"] = "Изменить контур шрифта для малой левой внутренней панели";

L["SETTING_FONTOUTLINE_LEFTSMALLBAR2"] = "Мал. лев. внеш. панель";
L["SETTING_FONTOUTLINE_LEFTSMALLBAR2_TOOLTIP"] = "Изменить контур шрифта для малой левой внешней панели";

L["SETTING_FONTOUTLINE_RIGHTBIGBAR1"] = "Бол. прав. внутр. панель";
L["SETTING_FONTOUTLINE_RIGHTBIGBAR1_TOOLTIP"] = "Изменить контур шрифта для большой правой внутренней панели";

L["SETTING_FONTOUTLINE_RIGHTBIGBAR2"] = "Бол. прав. внеш. панель";
L["SETTING_FONTOUTLINE_RIGHTBIGBAR2_TOOLTIP"] = "Изменить контур шрифта для большой правой внешней панели";

L["SETTING_FONTOUTLINE_RIGHTSMALLBAR1"] = "Мал. прав. внутр. панель";
L["SETTING_FONTOUTLINE_RIGHTSMALLBAR1_TOOLTIP"] = "Изменить контур шрифта для малой правой внутренней панели";

L["SETTING_FONTOUTLINE_RIGHTSMALLBAR2"] = "Мал. прав. внеш. панель";
L["SETTING_FONTOUTLINE_RIGHTSMALLBAR2_TOOLTIP"] = "Изменить контур шрифта для малой правой внешней панели";

L["SETTING_FONTOUTLINE_TARGETINFO1"] = "Верх. инф. о цели";
L["SETTING_FONTOUTLINE_TARGETINFO1_TOOLTIP"] = "Изменить контур шрифта для верхней панели информации о цели";

L["SETTING_FONTOUTLINE_TARGETINFO2"] = "Ниж. инф. о цели";
L["SETTING_FONTOUTLINE_TARGETINFO2_TOOLTIP"] = "Изменить контур шрифта для нижней панели информации о цели";

L["SETTING_FONTOUTLINE_SPELLCIRCLESTIME"] = "Время на круг. рамках";
L["SETTING_FONTOUTLINE_SPELLCIRCLESTIME_TOOLTIP"] = "Изменить контур шрифта для времени на круглых рамках заклинаний";

L["SETTING_FONTOUTLINE_SPELLCIRCLESSTACKS"] = "Кол-во на круг. рамках";
L["SETTING_FONTOUTLINE_SPELLCIRCLESSTACKS_TOOLTIP"] = "Изменить контур шрифта для количества на круглых рамках заклинаний";

L["SETTING_FONTOUTLINE_SPELLRECTANGLESTIME"] = "Время на прям. рамках";
L["SETTING_FONTOUTLINE_SPELLRECTANGLESTIME_TOOLTIP"] = "Изменить контур шрифта для времени на прямоугольных рамках заклинаний";

L["SETTING_FONTOUTLINE_SPELLRECTANGLESSTACKS"] = "Кол-во на прям. рамках";
L["SETTING_FONTOUTLINE_SPELLRECTANGLESSTACKS_TOOLTIP"] = "Изменить контур шрифта для количества на прямоугольных рамках заклинаний";

L["SETTING_FONTOUTLINE_RESOURCETIME"] = "Время ресурсов";
L["SETTING_FONTOUTLINE_RESOURCETIME_TOOLTIP"] = "Изменить контур шрифта для времени на рамках ресурсов, напр. Рун Рыцарей Смерти";

L["SETTING_FONTOUTLINE_CASTBARSTIME"] = "Время произн. закл.";
L["SETTING_FONTOUTLINE_CASTBARSTIME_TOOLTIP"] = "Изменить контур шрифта для времени на рамке произнесения заклинания";

L["SETTING_FONTOUTLINE_CASTBARSDELAY"] = "Задержка произ. закл.";
L["SETTING_FONTOUTLINE_CASTBARSDELAY_TOOLTIP"] = "Изменить контур шрифта для задержки на рамке произнесения заклинания";

L["SETTING_FONTOUTLINE_CASTBARSSPELL"] = "Название закл.";
L["SETTING_FONTOUTLINE_CASTBARSSPELL_TOOLTIP"] = "Изменить контур шрифта для названия заклинания на рамке произнесения заклинания";

-- general icons
L["HEADER_ICONS"] = "Иконки:";

L["SETTING_ICON_RESTING"] = "Иконка отдыха";
L["SETTING_ICON_RESTING_TOOLTIP"] = "Показывать иконку отдыха при нахождении в гостинице или городе";

L["SETTING_ICON_COMBAT"] = "Иконка боя";
L["SETTING_ICON_COMBAT_TOOLTIP"] = "Показывать иконку боя во время боя";

L["SETTING_ICON_SELFPVP"] = "PvP статус игрока";
L["SETTING_ICON_SELFPVP_TOOLTIP"] = "Показывать иконку PvP статуса игрока при включенном режиме PvP";

L["SETTING_ICON_TARGETPVP"] = "PvP статус цели";
L["SETTING_ICON_TARGETPVP_TOOLTIP"] = "Показывать иконку PvP статуса цели, еслу у цели активирован режим PvP";

L["SETTING_ICON_TARGETELITE"] = "Иконка дракона";
L["SETTING_ICON_TARGETELITE_TOOLTIP"] = "Показывать иконку дракона если целья является элитной или редкой";

L["SETTING_ICON_TARGETRAID"] = "Рейдовая метка цели";
L["SETTING_ICON_TARGETRAID_TOOLTIP"] = "Показывать рейдовую метку цели";

L["SETTING_ICON_TARGETSPECROLE"] = "Иконка роли цели";
L["SETTING_ICON_TARGETSPECROLE_TOOLTIP"] = "[НГ] Показывать иконку роли цели (только для игроков)";

L["SETTING_ICON_TARGETSPEC"] = "Иконка спец-ии цели";
L["SETTING_ICON_TARGETSPEC_TOOLTIP"] = "[НГ] Показывать иконку специализации цели (только для игроков)";

-- general textures
L["HEADER_TEXTURES"] = "Текстуры:";

L["SETTING_TEXTURES_BARS_1"] = "Сплошная";
L["SETTING_TEXTURES_BARS_1_TOOLTIP"] = "Изменить текстуры панели на сплошные";

L["SETTING_TEXTURES_BARS_2"] = "Пузырьки";
L["SETTING_TEXTURES_BARS_2_TOOLTIP"] = "Изменить текстуры панели на пузырьки";

L["SETTING_TEXTURES_BARS_3"] = "Кирпич";
L["SETTING_TEXTURES_BARS_3_TOOLTIP"] = "Изменить текстуры панели на кирпичную кладку";

L["SETTING_TEXTURES_BARS_4"] = "Шершавая";
L["SETTING_TEXTURES_BARS_4_TOOLTIP"] = "Изменить текстуры панели на шершавую";

L["SETTING_TEXTURES_BARS_5"] = "Туман";
L["SETTING_TEXTURES_BARS_5_TOOLTIP"] = "Изменить текстуры панели на туман";

L["SETTING_TEXTURES_BARS_BACKGROUND"] = "Фон";
L["SETTING_TEXTURES_BARS_BACKGROUND_TOOLTIP"] = "Показывать фоновую текстуру под панелями";

-- general health bar options
L["HEADER_HEALTHBAR"] = "Панели здоровья:";

L["SETTING_HEALTHBAR_SHIELDS"] = "Показ. щиты";
L["SETTING_HEALTHBAR_SHIELDS_TOOLTIP"] = "Если выставлено значение 2 - то сумма эффектов щита здоровья отображается выше максимума здоровья, если 1 - то не отображается выше максимума, если 0 - то не отображаются никогда";

L["SETTING_HEALTHBAR_HEALABSORBS"] = "Погл. исцелен.";
L["SETTING_HEALTHBAR_HEALABSORBS_TOOLTIP"] = "Позволяет показывать сумму эффектов поглощения исцеления (напр. Некротический удар) на панели и в тексте";

L["SETTING_HEALTHBAR_HEALINCOMING"] = "Вход. исцелен.";
L["SETTING_HEALTHBAR_HEALINCOMING_TOOLTIP"] = "Позволяет показывать сумму эффектов входящего исцеления на панели и в тексте";


-- general misc options
L["HEADER_MISC"] = "Прочие:";
L["HEADER_CASTBARS"] = "Панели закл.:";

L["SETTING_MISC_ANIMATEBARS"] = "Анимировать панели";
L["SETTING_MISC_ANIMATEBARS_TOOLTIP"] = "Позволяет анимировать панели с данными, иначе данные будут отображены сразу";

L["SETTING_MISC_REVERSECASTBARS"] = "Обр. произн. закл.";
L["SETTING_MISC_REVERSECASTBARS_TOOLTIP"] = "Позволяет обратить анимацию произнесения заклинаний";

L["SETTING_MISC_SHOWPLAYERCASTINFO"] = "Инф. о закл. игрока";
L["SETTING_MISC_SHOWPLAYERCASTINFO_TOOLTIP"] = "Позволяет отображать информацию о заклинании произносимом игроком";

L["SETTING_MISC_SHOWGCDONPLAYERCASTBAR"] = "Показ. ГКД";
L["SETTING_MISC_SHOWGCDONPLAYERCASTBAR_TOOLTIP"] = "Позволяет отображать глобальное время восстановления заклинаний на панели произнесения заклинаний";

L["SETTING_MISC_USECUSTOMAURASTRACKERS"] = "Улучш. отслеж. аур";
L["SETTING_MISC_USECUSTOMAURASTRACKERS_TOOLTIP"] = "Позволяет отслеживать некоторые ауры (напр. Коварство бандитов разбойников) дополнительно обрабатывая их";

L["SETTING_MISC_ALWAYSSHOWCASTBARBACKGROUND"] = "Фон панели закл.";
L["SETTING_MISC_ALWAYSSHOWCASTBARBACKGROUND_TOOLTIP"] = "Позволяет рисовать фоновую текстуру под панелью произнесения заклинаний независимо от возможности произнесения заклинаний боевой еденицей";

L["SETTING_MISC_SHOWMILLISECONDS"] = "Показывать мс";
L["SETTING_MISC_SHOWMILLISECONDS_TOOLTIP"] = "Позволяет отображать миллисекунды при форматировании времени.";

L["SETTING_MISC_SHORTNUMBERS"] = "Сокращ. числа";
L["SETTING_MISC_SHORTNUMBERS_TOOLTIP"] = "Позволяет сокращать длину текста при форматировании чисел, которые превышают 5 знаков.";

L["SETTING_MISC_MINIMAP"] = "Иконка у миникарты";
L["SETTING_MISC_MINIMAP_TOOLTIP"] = "Позволяет отображать иконку у миникарты.\nЕсли отключено опции можно открыть через меню интерфейса или через команду /dhud";

L["SETTING_MISC_HIDEINPETBATTLES"] = "Скрыв. в битв.питом.";
L["SETTING_MISC_HIDEINPETBATTLES_TOOLTIP"] = "Если выставлено, то панель будет скрыта целиком пока идет битва питомцев.";

L["SETTING_MISC_MOUSECONDITIONSMASK"] = "Условия мышки";
L["SETTING_MISC_MOUSECONDITIONSMASK_TOOLTIP"] = "Выберите условия, при которых будут обрабатываться события мышки для показа подсказок и выпадающего списка опций цели.";
L["SETTING_MISC_MOUSECONDITIONSMASK_MASK"] = {
	["UNSET"] = "Без условий",
	["ALT"] = "ALT",
	["CTRL"] = "CTRL",
	["SHIFT"] = "SHIFT",
};

-- layouts
L["HEADER_FRAMESDATA"] = "Данные панелей:";

L["SETTING_FRAMESDATA_LEFTBIGBAR1"] = "Бол. лев. внутр. панель";
L["SETTING_FRAMESDATA_LEFTBIGBAR1_TOOLTIP"] = "Изменить отображаемые данные для большой левой внутренней панели";

L["SETTING_FRAMESDATA_LEFTBIGBAR2"] = "Бол. лев. внеш. панель";
L["SETTING_FRAMESDATA_LEFTBIGBAR2_TOOLTIP"] = "Изменить отображаемые данные для большой левой внешней панели";

L["SETTING_FRAMESDATA_LEFTSMALLBAR1"] = "Мал. лев. внутр. панель";
L["SETTING_FRAMESDATA_LEFTSMALLBAR1_TOOLTIP"] = "Изменить отображаемые данные для малой левой внутренней панели";

L["SETTING_FRAMESDATA_LEFTSMALLBAR2"] = "Мал. лев. внеш. панель";
L["SETTING_FRAMESDATA_LEFTSMALLBAR2_TOOLTIP"] = "Изменить отображаемые данные для малой левой внешней панели";

L["SETTING_FRAMESDATA_RIGHTBIGBAR1"] = "Бол. прав. внутр. панель";
L["SETTING_FRAMESDATA_RIGHTBIGBAR1_TOOLTIP"] = "Изменить отображаемые данные для большой правой внутренней панели";

L["SETTING_FRAMESDATA_RIGHTBIGBAR2"] = "Бол. прав. внеш. панель";
L["SETTING_FRAMESDATA_RIGHTBIGBAR2_TOOLTIP"] = "Изменить отображаемые данные для большой правой внешней панели";

L["SETTING_FRAMESDATA_RIGHTSMALLBAR1"] = "Мал. прав. внутр. панель";
L["SETTING_FRAMESDATA_RIGHTSMALLBAR1_TOOLTIP"] = "Изменить отображаемые данные для малой правой внутренней панели";

L["SETTING_FRAMESDATA_RIGHTSMALLBAR2"] = "Мал. прав. внеш. панель";
L["SETTING_FRAMESDATA_RIGHTSMALLBAR2_TOOLTIP"] = "Изменить отображаемые данные для малой правой внешней панели";

L["SETTING_FRAMESDATA_TARGETINFO1"] = "Верх. инф. о цели";
L["SETTING_FRAMESDATA_TARGETINFO1_TOOLTIP"] = "Изменить отображаемые данные для верхней панели информации о цели";

L["SETTING_FRAMESDATA_TARGETINFO2"] = "Ниж. инф. о цели";
L["SETTING_FRAMESDATA_TARGETINFO2_TOOLTIP"] = "Изменить отображаемые данные для нижней панели информации о цели";

L["SETTING_FRAMESDATA_LEFTOUTERSIDE"] = "Левая внешняя область";
L["SETTING_FRAMESDATA_LEFTOUTERSIDE_TOOLTIP"] = "Изменить отображаемые данные для левой внешней области";

L["SETTING_FRAMESDATA_LEFTINNERSIDE"] = "Левая внутреняя область";
L["SETTING_FRAMESDATA_LEFTINNERSIDE_TOOLTIP"] = "Изменить отображаемые данные для правой внутренней области";

L["SETTING_FRAMESDATA_RIGHTOUTERSIDE"] = "Правая внешняя область";
L["SETTING_FRAMESDATA_RIGHTOUTERSIDE_TOOLTIP"] = "Изменить отображаемые данные для левой внешней области";

L["SETTING_FRAMESDATA_RIGHTINNERSIDE"] = "Правая внутреняя область";
L["SETTING_FRAMESDATA_RIGHTINNERSIDE_TOOLTIP"] = "Изменить отображаемые данные для правой внутренней области";

L["SETTING_FRAMESDATA_LEFTRECTANGLES"] = "Левые прям. рамки";
L["SETTING_FRAMESDATA_LEFTRECTANGLES_TOOLTIP"] = "Изменить отображаемые данные для левых прямоугольных рамок заклинаний";

L["SETTING_FRAMESDATA_RIGHTRECTANGLES"] = "Правые прям. рамки";
L["SETTING_FRAMESDATA_RIGHTRECTANGLES_TOOLTIP"] = "Изменить отображаемые данные для правых прямоугольных рамок заклинаний";

L["HEADER_FRAMESDATA_POSITION"] = "Позиции панелей:";

L["SETTING_FRAMESDATA_POSITION_SELFSTATE"] = "Позиция статуса игрока";
L["SETTING_FRAMESDATA_POSITION_SELFSTATE_TOOLTIP"] = "Изменить позицию иконок статуса игрока";

L["SETTING_FRAMESDATA_POSITION_TARGETSTATE"] = "Позиция статуса цели";
L["SETTING_FRAMESDATA_POSITION_TARGETSTATE_TOOLTIP"] = "Изменить позицию иконок статуса цели";

L["SETTING_FRAMESDATA_POSITION_TARGETDRAGON"] = "Позиция иконки дракона";
L["SETTING_FRAMESDATA_POSITION_TARGETDRAGON_TOOLTIP"] = "Изменить позицию иконки дракона цели";

L["HEADER_LAYOUTS"] = "Готовая разметка:";

L["SETTING_LAYOUTS_1"] = "Здор. слева - Рес. справа";
L["SETTING_LAYOUTS_1_TOOLTIP"] = "Показывать здоровье на левых панелях, а ресурсы на правых панелях";

L["SETTING_LAYOUTS_2"] = "Игрок слева - Цель справа";
L["SETTING_LAYOUTS_2_TOOLTIP"] = "Показывать информацию об игроке слева, а информацию о цели справа";

L["SETTING_LAYOUTS_0"] = "Вручную";
L["SETTING_LAYOUTS_0_TOOLTIP"] = "Показывать информацию на панелях по выбору игрока";

L["SETTING_LAYOUTS_DATA_SOURCES"] = {
	["playerHealth"] = "Игрок: Здоровье",
	["targetHealth"] = "Цель: Здоровье",
	["characterInVehicleHealth"] = "Игрок: Здоровье персонажа в машине",
	["petHealth"] = "Питомец: Здоровье",
	["playerPower"] = "Игрок: Основной Ресурс",
	["targetPower"] = "Цель: Основной Ресурс",
	["characterInVehiclePower"] = "Игрок: Ресурс персонажа в машине",
	["petPower"] = "Питомец: Ресурс",
	["playerCastBar"] = "Игрок: Информ. о произн. закл.",
	["targetCastBar"] = "Цель: Информ. о произн. закл.",
	["playerComboPoints"] = "Игрок: Комбо-очки",
	["vehicleComboPoints"] = "Машины: Комбо-очки",
	["playerCooldowns"] = "Игрок: Восстановление закл.",
	["playerShortAuras"] = "Игрок: Коротк. Ауры",
	["targetShortAuras"] = "Цель: Коротк. Ауры",
	["targetInfo"] = "Цель: Информация о цели",
	["targetOfTargetInfo"] = "Цель цели: Информация о цели",
	["targetBuffs"] = "Цель: Полож. ауры",
	["targetDebuffs"] = "Цель: Отриц. ауры",
	["druidMana"] = "Игрок: Мана при смене облика",
	["druidEnergy"] = "Игрок: Энергия вне облика кота",
	["druidEclipse"] = "Игрок: Друид. Затмение",
	["monkChi"] = "Игрок: Монах. Энергия Ци",
	["monkMana"] = "Игрок: Мана вне стойки змеи",
	["monkEnergy"] = "Игрок: Энергия в стойке змеи",
	["monkStagger"] = "Игрок: Монах. Пошатывание",
	["warlockSoulShards"] = "Игрок: Чернокниж. Осколки Души",
	["warlockBurningEmbers"] = "Игрок: Чернокниж. Горящие угли",
	["warlockDemonicFury"] = "Игрок: Чернокниж. Демон. Ярость",
	["paladinHolyPower"] = "Игрок: Паладин. Святая Сила",
	["priestShadowOrbs"] = "Игрок: Жрец. Темные Сферы",
	["mageArcaneCharges"] = "Игрок: Маг Чародейские Заряды",
	["deathKnightRunes"] = "Игрок: Рыцарь Смерти. Руны",
	["shamanTotems"] = "Игрок: Шаман. Тотемы",
	["shamanMana"] = "Игрок: Мана вне спец-ии исцеления",
	["tankVengeance"] = "Игрок: Отмщение танков",
};
L["SETTING_LAYOUTS_DATA_POSITIONS"] = {
	["LEFT"] = "Слева",
	["CENTER"] = "По-центру",
	["RIGHT"] = "Справа",
};

-- timers
L["HEADER_TIMERS_GENERAL"] = "Таймеры:";

L["SETTING_TIMERS_TIMERSFORTARGETBUFFS"] = "Тайм. баффов цели";
L["SETTING_TIMERS_TIMERSFORTARGETBUFFS_TOOLTIP"] = "Показывать время на таймерах положительных эффектов цели";

L["SETTING_TIMERS_TIMERSFORTARGETDEBUFFS"] = "Тайм. дебаффов цели";
L["SETTING_TIMERS_TIMERSFORTARGETDEBUFFS_TOOLTIP"] = "Показывать время на таймерах отрицательных эффектов цели";

L["HEADER_TIMERS_SHORTAURAS"] = "Короткие Ауры:";

L["SETTING_TIMERS_SHORTAURASWITHCHARGES"] = "Короткие ауры с зарядами";
L["SETTING_TIMERS_SHORTAURASWITHCHARGES_TOOLTIP"] = "Показывать короткие ауры с ненулевым количество зарядов, независимо от оставшегося времени ауры";

L["SETTING_TIMERS_SHORTAURASTIMELEFT"] = "Макс. время коротких аур";
L["SETTING_TIMERS_SHORTAURASTIMELEFT_TOOLTIP"] = "Максимальное время для коротких аур игрока и цели, чтобы они считались подходящими для отображения на панелях";

L["SETTING_TIMERS_ANIMATEPRIORITYAURASATEND"] = "Аним. приоритет. ауры на 30%";
L["SETTING_TIMERS_ANIMATEPRIORITYAURASATEND_TOOLTIP"] = "Позволяет анимировать приоритетные ауры, когда на них осталось менее 30% времени";

L["SETTING_TIMERS_ANIMATEPRIORITYAURASDISAPPEAR"] = "Аним. приоритет. ауры на исчез.";
L["SETTING_TIMERS_ANIMATEPRIORITYAURASDISAPPEAR_TOOLTIP"] = "Позволяет анимировать приоритетные ауры, когда на них осталось меньше 1 секунды";

L["HEADER_TIMERS_PLAYERSHORT"] = "Коротк. Ауры Игрока:";

L["SETTING_TIMERS_PLAYERSHORT_ALLBUFFS"] = "Показ. все баффы";
L["SETTING_TIMERS_PLAYERSHORT_ALLBUFFS_TOOLTIP"] = "Позволяет отображать все положительные эффекты на игроке, не только сотворенные самим игроком";

L["SETTING_TIMERS_PLAYERSHORT_DEBUFFS"] = "Показ. дебафф";
L["SETTING_TIMERS_PLAYERSHORT_DEBUFFS_TOOLTIP"] = "Позволяет отображать также и отрицательные эффекты на игроке";

L["SETTING_TIMERS_PLAYERSHORT_COLORIZEDEBUFFS"] = "Перекраш. дебаффы";
L["SETTING_TIMERS_PLAYERSHORT_COLORIZEDEBUFFS_TOOLTIP"] = "Изменять цвет таймеров с отрицательными эффектами в зависимости от типа отрицательного эффекта";

L["SETTING_TIMERS_PLAYERSHORT_WHITELIST"] = "Белый список";
L["SETTING_TIMERS_PLAYERSHORT_WHITELIST_TOOLTIP"] = "Список аур, которые должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_PLAYERSHORT_BLACKLIST"] = "Черный список";
L["SETTING_TIMERS_PLAYERSHORT_BLACKLIST_TOOLTIP"] = "Список аур, которые не должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_PLAYERSHORT_PRIORITYLIST"] = "Список приоритетов";
L["SETTING_TIMERS_PLAYERSHORT_PRIORITYLIST_TOOLTIP"] = "Список аур, которые должны отображаться вначале списка";

L["HEADER_TIMERS_TARGETSHORT"] = "Коротк. Ауры Цели:";

L["SETTING_TIMERS_TARGETSHORT_WHITELIST"] = "Белый список";
L["SETTING_TIMERS_TARGETSHORT_WHITELIST_TOOLTIP"] = "Список аур, которые должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_TARGETSHORT_BLACKLIST"] = "Черный список";
L["SETTING_TIMERS_TARGETSHORT_BLACKLIST_TOOLTIP"] = "Список аур, которые не должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_TARGETSHORT_PRIORITYLIST"] = "Список приоритетов";
L["SETTING_TIMERS_TARGETSHORT_PRIORITYLIST_TOOLTIP"] = "Список аур, которые должны отображаться вначале списка";

L["HEADER_TIMERS_PLAYERCOOLDOWNS"] = "Восстановление закл.:";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMIN"] = "Минимальная длительность";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMIN_TOOLTIP"] = "Минимальная длительность восстановления, чтобы оно считались подходящим для отображения на панели";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMAX"] = "Максимальная длительность";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMAX_TOOLTIP"] = "Максимальная длительность восстановления, чтобы оно считались подходящим для отображения на панели";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_ITEM"] = "Восстановление предм.";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_ITEM_TOOLTIP"] = "Показывать восстановление предметов, учтите что вы можете запретить показ отдельных предметов по имени или номеру слота";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_COLORIZELOCKS"] = "Перекраш. сбитие школы";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_COLORIZELOCKS_TOOLTIP"] = "Изменять цвет таймеров с кулдаунами в зависимости от типа сбитой школы";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_WHITELIST"] = "Белый список";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_WHITELIST_TOOLTIP"] = "Список восстановлений, которые должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_BLACKLIST"] = "Черный список";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_BLACKLIST_TOOLTIP"] = "Список восстановлений, которые не должны отображаться на панели независимо от оставшегося времени и зарядов";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_PRIORITYLIST"] = "Список приоритетов";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_PRIORITYLIST_TOOLTIP"] = "Список восстановлений, которые должны отображаться вначале списка";

-- colors
L["HEADER_COLORS_PLAYER"] = "Игрок:";

L["SETTING_COLORS_PLAYER_HEALTH"] = "Здоровье";
L["SETTING_COLORS_PLAYER_HEALTH_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Здоровья Игрока";

L["SETTING_COLORS_PLAYER_HEALTHSHIELD"] = "Щит здоровья";
L["SETTING_COLORS_PLAYER_HEALTHSHIELD_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Щита Здоровья Игрока";

L["SETTING_COLORS_PLAYER_HEALTHHEALABSORB"] = "Поглощение исц.";
L["SETTING_COLORS_PLAYER_HEALTHHEALABSORB_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Поглощенного Исцеления на Игроке";

L["SETTING_COLORS_PLAYER_HEALTHHEALINCOMING"] = "Входящее исц.";
L["SETTING_COLORS_PLAYER_HEALTHHEALINCOMING_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Входящего Исцеления по Игроку";

L["SETTING_COLORS_PLAYER_MANA"] = "Мана";
L["SETTING_COLORS_PLAYER_MANA_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Маны Игрока";

L["SETTING_COLORS_PLAYER_RAGE"] = "Ярость";
L["SETTING_COLORS_PLAYER_RAGE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Ярости Игрока";

L["SETTING_COLORS_PLAYER_ENERGY"] = "Энергия";
L["SETTING_COLORS_PLAYER_ENERGY_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Энергии Игрока";

L["SETTING_COLORS_PLAYER_RUNICPOWER"] = "Руническая сила";
L["SETTING_COLORS_PLAYER_RUNICPOWER_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Рунической Силы Игрока";

L["SETTING_COLORS_PLAYER_FOCUS"] = "Концентрация";
L["SETTING_COLORS_PLAYER_FOCUS_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Концентрации Игрока";

L["SETTING_COLORS_PLAYER_CAST"] = "Произн. закл.";
L["SETTING_COLORS_PLAYER_CAST_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Произнесения Заклинания Игрока";

L["SETTING_COLORS_PLAYER_CHANNEL"] = "Поддержание закл.";
L["SETTING_COLORS_PLAYER_CHANNEL_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Поддерживания Заклинания Игрока";

L["SETTING_COLORS_PLAYER_LOCKEDCAST"] = "Произн. несбив. з.";
L["SETTING_COLORS_PLAYER_LOCKEDCAST_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Произнесения Несбиваемого Заклинания Игрока";

L["SETTING_COLORS_PLAYER_LOCKEDCHANNEL"] = "Поддер. несбив. з.";
L["SETTING_COLORS_PLAYER_LOCKEDCHANNEL_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Поддерживания Несбиваемого Заклинания Игрока";

L["SETTING_COLORS_PLAYER_CASTINTERRUPTED"] = "Сбитое произн. з.";
L["SETTING_COLORS_PLAYER_CASTINTERRUPTED_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Сбитого Произнесения Заклинания Игрока";

L["SETTING_COLORS_PLAYER_SHORTAURABUFF"] = "Корот. пол. ауры";
L["SETTING_COLORS_PLAYER_SHORTAURABUFF_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Положительных Коротких Аур Игрока";

L["SETTING_COLORS_PLAYER_SHORTAURADEBUFF"] = "Корот. отр. ауры";
L["SETTING_COLORS_PLAYER_SHORTAURADEBUFF_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Отрицательных Коротких Аур Игрока";

L["SETTING_COLORS_PLAYER_COOLDOWNSSPELL"] = "Восстан. закл.";
L["SETTING_COLORS_PLAYER_COOLDOWNSSPELL_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Восстановления Заклинаний Игрока";

L["SETTING_COLORS_PLAYER_COOLDOWNSITEM"] = "Восстан. предм.";
L["SETTING_COLORS_PLAYER_COOLDOWNSITEM_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Восстановления Предметов Игрока";

L["HEADER_COLORS_TARGET"] = "Цель:";

L["SETTING_COLORS_TARGET_HEALTH"] = "Здоровье";
L["SETTING_COLORS_TARGET_HEALTH_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Здоровья Цели";

L["SETTING_COLORS_TARGET_HEALTHSHIELD"] = "Щит здоровья";
L["SETTING_COLORS_TARGET_HEALTHSHIELD_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Щита Здоровья Цели";

L["SETTING_COLORS_TARGET_HEALTHHEALABSORB"] = "Поглощение исц.";
L["SETTING_COLORS_TARGET_HEALTHHEALABSORB_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Поглощенного Исцеления на Цели";

L["SETTING_COLORS_TARGET_HEALTHHEALINCOMING"] = "Входящее исц.";
L["SETTING_COLORS_TARGET_HEALTHHEALINCOMING_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Входящего Исцеления по Цели";

L["SETTING_COLORS_TARGET_HEALTHNOTTAPPED"] = "Здоровье без доб.";
L["SETTING_COLORS_TARGET_HEALTHNOTTAPPED_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Здоровья Цели, за которую не дадут добычи";

L["SETTING_COLORS_TARGET_MANA"] = "Мана";
L["SETTING_COLORS_TARGET_MANA_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Маны Цели";

L["SETTING_COLORS_TARGET_RAGE"] = "Ярость";
L["SETTING_COLORS_TARGET_RAGE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Ярости Цели";

L["SETTING_COLORS_TARGET_ENERGY"] = "Энергия";
L["SETTING_COLORS_TARGET_ENERGY_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Энергии Цели";

L["SETTING_COLORS_TARGET_RUNICPOWER"] = "Руническая сила";
L["SETTING_COLORS_TARGET_RUNICPOWER_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Рунической Силы Цели";

L["SETTING_COLORS_TARGET_FOCUS"] = "Концентрация";
L["SETTING_COLORS_TARGET_FOCUS_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Концентрации Цели";

L["SETTING_COLORS_TARGET_CAST"] = "Произн. закл.";
L["SETTING_COLORS_TARGET_CAST_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Произнесения Заклинания Цели";

L["SETTING_COLORS_TARGET_CHANNEL"] = "Поддержание закл.";
L["SETTING_COLORS_TARGET_CHANNEL_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Поддерживания Заклинания Цели";

L["SETTING_COLORS_TARGET_LOCKEDCAST"] = "Произн. несбив. з.";
L["SETTING_COLORS_TARGET_LOCKEDCAST_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Произнесения Несбиваемого Заклинания Цели";

L["SETTING_COLORS_TARGET_LOCKEDCHANNEL"] = "Поддер. несбив. з.";
L["SETTING_COLORS_TARGET_LOCKEDCHANNEL_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Поддерживания Несбиваемого Заклинания Цели";

L["SETTING_COLORS_TARGET_CASTINTERRUPTED"] = "Сбитое произн. з.";
L["SETTING_COLORS_TARGET_CASTINTERRUPTED_TOOLTIP"] = "Цвет, который должен быть использован на панели заклинаний при отображении Сбитого Произнесения Заклинания Цели";

L["SETTING_COLORS_TARGET_PLAYERSHORTAURA"] = "Корот. ауры игр.";
L["SETTING_COLORS_TARGET_PLAYERSHORTAURA_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Коротких Аур Цели, Наложенных Игроком";

L["SETTING_COLORS_TARGET_SHORTAURABUFF"] = "Корот. пол. ауры";
L["SETTING_COLORS_TARGET_SHORTAURABUFF_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Положительных Коротких Аур Цели";

L["SETTING_COLORS_TARGET_SHORTAURADEBUFF"] = "Корот. отр. ауры";
L["SETTING_COLORS_TARGET_SHORTAURADEBUFF_TOOLTIP"] = "Цвет, который должен быть использован на круглых рамках заклинаний при отображении Отрицательных Коротких Аур Игрока";

L["SETTING_COLORS_TARGET_AURABUFF"] = "Полож. Ауры";
L["SETTING_COLORS_TARGET_AURABUFF_TOOLTIP"] = "Цвет, который должен быть использован на прямоугольных рамках заклинаний при отображении Положительных Аур Цели";

L["SETTING_COLORS_TARGET_AURADEBUFF"] = "Отриц. Ауры";
L["SETTING_COLORS_TARGET_AURADEBUFF_TOOLTIP"] = "Цвет, который должен быть использован на прямоугольных рамках заклинаний при отображении Отрицательных Аур Цели";

L["HEADER_COLORS_PET"] = "Питомец:";

L["SETTING_COLORS_PET_HEALTH"] = "Здоровье";
L["SETTING_COLORS_PET_HEALTH_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Здоровья Питомца";

L["SETTING_COLORS_PET_HEALTHSHIELD"] = "Щит здоровья";
L["SETTING_COLORS_PET_HEALTHSHIELD_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Щита Здоровья Питомца";

L["SETTING_COLORS_PET_HEALTHHEALABSORB"] = "Поглощение исц.";
L["SETTING_COLORS_PET_HEALTHHEALABSORB_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Поглощенного Исцеления на Питомце";

L["SETTING_COLORS_PET_HEALTHHEALINCOMING"] = "Входящее исц.";
L["SETTING_COLORS_PET_HEALTHHEALINCOMING_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Входящего Исцеления по Питомцу";

L["SETTING_COLORS_PET_MANA"] = "Мана";
L["SETTING_COLORS_PET_MANA_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Маны Питомца";

L["SETTING_COLORS_PET_FOCUS"] = "Концентрация";
L["SETTING_COLORS_PET_FOCUS_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Концентрации Питомца";

L["SETTING_COLORS_PET_ENERGY"] = "Энергия";
L["SETTING_COLORS_PET_ENERGY_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Энергии Питомца";

L["HEADER_COLORS_ALTERNATIVEPOWER"] = "Альтерн. рес. игрока:";

L["SETTING_COLORS_GUARDIAN_ACTIVE"] = "А.Тотемы";
L["SETTING_COLORS_GUARDIAN_ACTIVE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Активных Тотемов Игрока";

L["SETTING_COLORS_GUARDIAN_PASSIVE"] = "П.Тотемы";
L["SETTING_COLORS_GUARDIAN_PASSIVE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Пассивных Тотемов Игрока, создаваемых глифом, напр. Тотем Земли";

L["SETTING_COLORS_ALTERNATIVEPOWER_ECLIPSE"] = "Затмение";
L["SETTING_COLORS_ALTERNATIVEPOWER_ECLIPSE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Затмения Игрока";

L["SETTING_COLORS_ALTERNATIVEPOWER_MAELSTROM"] = "Эн. Круговорота";
L["SETTING_COLORS_ALTERNATIVEPOWER_MAELSTROM_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Энергии Круговорота Игрока";

L["SETTING_COLORS_ALTERNATIVEPOWER_FURY"] = "Ярость";
L["SETTING_COLORS_ALTERNATIVEPOWER_FURY_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Ярости Игрока";

L["SETTING_COLORS_ALTERNATIVEPOWER_PAIN"] = "Боль";
L["SETTING_COLORS_ALTERNATIVEPOWER_PAIN_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Боли Игрока";

L["SETTING_COLORS_ALTERNATIVEPOWER_BURNINGEMBERS"] = "Горящие Угли";
L["SETTING_COLORS_ALTERNATIVEPOWER_BURNINGEMBERS_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Горящих углей Игрока";

L["SETTING_COLORS_ALTERNATIVEPOWER_DEMONICFURY"] = "Демон. Ярость";
L["SETTING_COLORS_ALTERNATIVEPOWER_DEMONICFURY_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Демонической Ярости Игрока";

L["SETTING_COLORS_OTHERPOWER_VENGEANCE"] = "Отмщение";
L["SETTING_COLORS_OTHERPOWER_VENGEANCE_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Танковского Отмщения";

L["SETTING_COLORS_OTHERPOWER_STAGGER"] = "Пошатывание";
L["SETTING_COLORS_OTHERPOWER_STAGGER_TOOLTIP"] = "Цвет, который должен быть использован на панели и в тексте при отображении Пошатывания Монахов - Пивоваров";

-- unit texts
L["HEADER_UNITTEXTS_PLAYER"] = "Игрок:";

L["SETTING_UNITTEXTS_PLAYER_HEALTH"] = "Здоровье Игрока";
L["SETTING_UNITTEXTS_PLAYER_HEALTH_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Здоровья Игрока";

L["SETTING_UNITTEXTS_PLAYER_POWER"] = "Ресурс Игрока";
L["SETTING_UNITTEXTS_PLAYER_POWER_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Основного Ресурса Игрока";

L["SETTING_UNITTEXTS_PLAYER_ALTPOWER"] = "Альтернат. Ресурс Игрока";
L["SETTING_UNITTEXTS_PLAYER_ALTPOWER_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Альтернативного Ресурса Игрока";

L["SETTING_UNITTEXTS_PLAYER_OTHERPOWER"] = "Прочие Ресурсы Игрока";
L["SETTING_UNITTEXTS_PLAYER_OTHERPOWER_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Прочих ресурсов игрока, напр. Пошатывание Монахов, Отмщение танков, и пр.";

L["SETTING_UNITTEXTS_PLAYER_CASTTIME"] = "Время Произ. закл. Игрока";
L["SETTING_UNITTEXTS_PLAYER_CASTTIME_TOOLTIP"] = "Изменить текст времени отображаемый рядом с панелью Произнесения Заклинания Игрока";

L["SETTING_UNITTEXTS_PLAYER_CASTDELAY"] = "Задер. Произ. закл. Игрока";
L["SETTING_UNITTEXTS_PLAYER_CASTDELAY_TOOLTIP"] = "Изменить текст задержки отображаемый рядом с панелью Произнесения Заклинания Игрока";

L["SETTING_UNITTEXTS_PLAYER_CASTNAME"] = "Назв. Произ. закл. Игрока";
L["SETTING_UNITTEXTS_PLAYER_CASTNAME_TOOLTIP"] = "Изменить текст названия заклинания отображаемый рядом с панелью Произнесения Заклинания Игрока";

L["HEADER_UNITTEXTS_TARGET"] = "Цель:";

L["SETTING_UNITTEXTS_TARGET_HEALTH"] = "Здоровье Цели";
L["SETTING_UNITTEXTS_TARGET_HEALTH_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Здоровья Цели";

L["SETTING_UNITTEXTS_TARGET_POWER"] = "Ресурс Цели";
L["SETTING_UNITTEXTS_TARGET_POWER_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Основного Ресурса Цели";

L["SETTING_UNITTEXTS_TARGET_CASTTIME"] = "Время Произ. закл. Цели";
L["SETTING_UNITTEXTS_TARGET_CASTTIME_TOOLTIP"] = "Изменить текст времени отображаемый рядом с панелью Произнесения Заклинания Цели";

L["SETTING_UNITTEXTS_TARGET_CASTDELAY"] = "Задер. Произ. закл. Цели";
L["SETTING_UNITTEXTS_TARGET_CASTDELAY_TOOLTIP"] = "Изменить текст задержки отображаемый рядом с панелью Произнесения Заклинания Цели";

L["SETTING_UNITTEXTS_TARGET_CASTNAME"] = "Назв. Произ. закл. Цели";
L["SETTING_UNITTEXTS_TARGET_CASTNAME_TOOLTIP"] = "Изменить текст названия заклинания отображаемый рядом с панелью Произнесения Заклинания Цели";

L["SETTING_UNITTEXTS_TARGET_INFO"] = "Информация о цели";
L["SETTING_UNITTEXTS_TARGET_INFO_TOOLTIP"] = "Изменить текст отображаемый на панели информации о Цели";

L["HEADER_UNITTEXTS_TARGETTARGET"] = "Цель цели:";

L["SETTING_UNITTEXTS_TARGETTARGET_INFO"] = "Информация о цели цели";
L["SETTING_UNITTEXTS_TARGETTARGET_INFO_TOOLTIP"] = "Изменить текст отображаемый на панели информации о Цели Цели";

L["HEADER_UNITTEXTS_PET"] = "Питомец:";

L["SETTING_UNITTEXTS_PET_HEALTH"] = "Здоровье Питомца";
L["SETTING_UNITTEXTS_PET_HEALTH_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Здоровья Питомца";

L["SETTING_UNITTEXTS_PET_POWER"] = "Ресурс Питомца";
L["SETTING_UNITTEXTS_PET_POWER_TOOLTIP"] = "Изменить текст отображаемый рядом с панелью Основного Ресурса Питомца";

L["SETTING_UNITTEXTS_PREDEFINED_CUSTOM"] = {
	["health1"] = "50 +...",
	["health2"] = "50/100 +...",
	["health3"] = "50% +...",
	["health4"] = "50 (50%) +...",
	["health5"] = "50/100 (50%) +...",
	["power1"] = "50",
	["power2"] = "50/100",
	["power3"] = "50%",
	["power4"] = "50 (50%)",
	["power5"] = "50/100 (50%)",
	["power6"] = "50.4",
	["unitInfo1"] = "Длинная",
	["unitInfo2"] = "Средняя",
	["unitInfo3"] = "Короткая",
	["castTime1"] = "Время закл.",
	["castTime2"] = "Оставш. время закл.",
	["castDelay1"] = "Задержка закл.",
	["castSpellName1"] = "Название закл.",
};
L["SETTING_UNITTEXTS_PREDEFINED_ALL"] = {
	["empty"] = "Пусто",
	["custom"] = "Определяется пользователем",
};

-- offsets
L["HEADER_OFFSETS"] = "Сдвиг:";

L["SETTING_OFFSET_HUD"] = "Позиция панели";
L["SETTING_OFFSET_HUD_TOOLTIP"] = "Передвинуть панель целиком, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_BARDISTANCE"] = "Дистация между панелями";
L["SETTING_OFFSET_BARDISTANCE_TOOLTIP"] = "Изменить дистанцию между панелями, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_TARGETINFO"] = "Верх. инф. о цели";
L["SETTING_OFFSET_TARGETINFO_TOOLTIP"] = "Передвинуть позицию текста верхней панели информации о цели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_TARGETINFO2"] = "Ниж. инф. о цели";
L["SETTING_OFFSET_TARGETINFO2_TOOLTIP"] = "Передвинуть позицию текста верхней панели информации о цели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_LEFTBIGBAR1"] = "Бол. лев. внутр. панель";
L["SETTING_OFFSET_LEFTBIGBAR1_TOOLTIP"] = "Передвинуть позицию текста Большой Левой Внутренней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_LEFTBIGBAR2"] = "Бол. лев. внеш. панель";
L["SETTING_OFFSET_LEFTBIGBAR2_TOOLTIP"] = "Передвинуть позицию текста Большой Левой Внешней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_LEFTSMALLBAR1"] = "Мал. лев. внутр. панель";
L["SETTING_OFFSET_LEFTSMALLBAR1_TOOLTIP"] = "Передвинуть позицию текста Малой Левой Внутренней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_LEFTSMALLBAR2"] = "Мал. лев. внеш. панель";
L["SETTING_OFFSET_LEFTSMALLBAR2_TOOLTIP"] = "Передвинуть позицию текста Малой Левой Внешней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_RIGHTBIGBAR1"] = "Бол. прав. внутр. панель";
L["SETTING_OFFSET_RIGHTBIGBAR1_TOOLTIP"] = "Передвинуть позицию текста Большой Правой Внутренней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_RIGHTBIGBAR2"] = "Бол. прав. внеш. панель";
L["SETTING_OFFSET_RIGHTBIGBAR2_TOOLTIP"] = "Передвинуть позицию текста Большой Правой Внешней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_RIGHTSMALLBAR1"] = "Мал. прав. внутр. панель";
L["SETTING_OFFSET_RIGHTSMALLBAR1_TOOLTIP"] = "Передвинуть позицию текста Малой Правой Внутренней Панели, используйте правый клик для ускоренного смещения";

L["SETTING_OFFSET_RIGHTSMALLBAR2"] = "Мал. прав. внеш. панель";
L["SETTING_OFFSET_RIGHTSMALLBAR2_TOOLTIP"] = "Передвинуть позицию текста Малой Правой Внешней Панели, используйте правый клик для ускоренного смещения";

-- service
L["HEADER_SERVICE_LUA"] = "LUA код:";

L["SETTING_SERVICE_LUA_ONLOAD"] = "Загрузочный LUA код:";
L["SETTING_SERVICE_LUA_ONLOAD_TOOLTIP"] = "LUA код, который будет выполнен после загрузки игры, полезно для изменения таких вещей как макс. дистанция камеры";

L["HEADER_SERVICE_BLIZZARD"] = "Стандартные фреймы:";

L["SETTING_SERVICE_ERRORS"] = "Фильтрация ошибок";
L["SETTING_SERVICE_ERRORS_TOOLTIP"] = "Изменения уровня отображаемых ошибок (напр. Недостаточно энергии), 0 - все ошибки отображаются, 1 - ошибки скрыты, 2 - панель ошибок скрыта (квестовые сообщения не отображаются)";
