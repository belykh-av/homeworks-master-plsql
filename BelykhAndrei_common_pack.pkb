CREATE OR REPLACE PACKAGE BODY common_pack is
  --Флаг использования глобального API для венения прямых изменений в таблицы
  g_is_api boolean := true;

  ----------------------------------------------------------------------------------------------------------------------
  --Включить использование глобального API
  procedure enable_api is
  begin
    if not g_is_api then
      g_is_api := true;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Выключить использование глобального API
  procedure disable_api is
  begin
    if g_is_api then
      g_is_api := false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Получить флаг использования глобального API
  function is_api
    return boolean is
  begin
    return g_is_api;
  end;
end common_pack;
/
