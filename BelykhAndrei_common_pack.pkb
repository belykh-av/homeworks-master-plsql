create or replace package body common_pack is
  --Флаг использования глобального API для венения прямых изменений в таблицы
  g_is_api boolean := true;

  ----------------------------------------------------------------------------------------------------------------------
  --Включить использование API
  procedure enable_api is
  begin
    if not g_is_api then
      g_is_api := true;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Выключить использование API
  procedure disable_api is
  begin
    if g_is_api then
      g_is_api := false;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Получить флаг использования API
  function is_api
    return boolean is
  begin
    return g_is_api;
  end;

end common_pack;