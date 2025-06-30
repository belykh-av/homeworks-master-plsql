CREATE OR REPLACE PACKAGE common_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Общий пакет
  -- Автор: Белых Андрей
  -- 04.06.2025. Создано в ДЗ16 (Доводим API "до ума").
  -- 08.06.2025. Доработано в рамках ДЗ17 (Блокировки).
  -- 29.06.2025. По замечаниям ДЗ19 вынес отсюда в PAYMENT_PACK и PAYMENT_DETAIL_PACK все константы и исключения, касающиеся этих API
  --
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --Валюта:
  c_currency_id_rub constant currency.currency_id%type := 643; --Российский рубль
  c_currency_id_usd constant currency.currency_id%type := 840; --Доллар США
  c_currency_id_eur constant currency.currency_id%type := 978; --Евро

  --Коды ошибок:
  c_error_code_system_resource_busy constant number := -00054;
  c_error_code_common_api_restriction constant number := -20099;

  --Сообщения об ошибках:
  c_error_message_common_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицы можно вносить только через API' ;

  ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  --
  e_system_resource_busy exception; --resource busy and acquire with NOWAIT specified or timeout expired
  pragma exception_init(e_system_resource_busy , c_error_code_system_resource_busy);
  --
  e_common_api_restriction exception; --Внесение любых изменений только через API
  pragma exception_init(e_common_api_restriction, c_error_code_common_api_restriction);
  --
  ----------------------------------------------------------------------------------------------------------------------
  --ПРОЦЕДУРЫ И ФУНКЦИИ:

  --Включить использование глобального API
  procedure enable_api;

  --Выключить использование глобального API
  procedure disable_api;

  --Получить флаг использования глобального API
  function is_api
    return boolean;
end common_pack;
/
