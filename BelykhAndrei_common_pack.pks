create or replace package common_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Общий пакет
  -- Автор: Белых Андрей
  -- 04.06.2025. Создано в ДЗ16 (Доводим API "до ума").
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --Статус платежа:
  c_status_created constant payment.status%type := 0; --Создан
  c_status_completed constant payment.status%type := 1; --Проведен
  c_status_failed constant payment.status%type := 2; --Ошибка проведения
  c_status_canceled constant payment.status%type := 3; --Отмена платежа

  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"

  --Статус изменения платежа:
  c_status_change_reason_no_money constant payment.status_change_reason%type
    := 'недостаточно средств' ;
  c_status_change_reason_user_error constant payment.status_change_reason%type
    := 'ошибка пользователя' ;

  --Валюта:
  c_currency_id_rub constant currency.currency_id%type := 643; --Российский рубль
  c_currency_id_usd constant currency.currency_id%type := 840; --Доллар США
  c_currency_id_eur constant currency.currency_id%type := 978; --Евро

  --Коды ошибок:
  --  common:
  c_error_code_common_api_restriction constant number := -20099;
  --  payment:
  c_error_code_payment_api_restriction constant number := -20100;
  c_error_code_empty_payment_id constant number := -20101;
  c_error_code_empty_status constant number := -20102;
  c_error_code_empty_status_change_reason constant number := -20103;
  c_error_code_payment_not_found constant number := -20104;
  c_error_code_status_error constant number := -20105;
  c_error_code_delete_restriction constant number := -20106;  
  --  payment_detail:
  c_error_code_payment_detail_api_restriction constant number := -20200;
  c_error_code_empty_payment_details constant number := -20201;
  c_error_code_empty_field_id constant number := -20202;
  c_error_code_empty_field_value constant number := -20203;

  --Сообщения об ошибках:
  --  api:
  c_error_message_common_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицы можно вносить только через API' ;
  --  payment:
  c_error_message_payment_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицу PAYMENT можно вносить только через API' ;
  c_error_message_empty_payment_id constant varchar2(100 char)
    := 'ID объекта не может быть пустым' ;
  c_error_message_empty_status constant varchar2(100 char) := 'Не задан статус';
  c_error_message_empty_status_change_reason constant varchar2(100 char)
    := 'Причина не может быть пустой' ;
  c_error_message_payment_not_found constant varchar2(100 char) := 'Не найден платеж';
  c_error_message_status_error constant varchar2(100 char) := 'Ошибка статуса платежа';
  c_error_message_delete_restriction constant varchar2(100 char)
    := 'Удаление платежей запрещено' ;
  --  payment_detail:  
  c_error_message_payment_detail_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицу PAYMENT_DETAIL можно вносить только через API' ;  
  c_error_message_empty_payment_details constant varchar2(100 char)
    := 'Коллекция не содержит данных' ;
  c_error_message_empty_field_id constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_message_empty_field_value constant varchar2(100 char)
    := 'Значение в поле не может быть пустым' ;

  ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  --cpommon:
  e_common_api_restriction exception; --Внесение любых изменений только через API
  pragma exception_init(e_common_api_restriction, c_error_code_common_api_restriction);
  --
  --payment:
  e_payment_api_restriction exception; --Внесение изменений в PAYMENT только через API
  pragma exception_init(e_payment_api_restriction, c_error_code_payment_api_restriction);
  --
  e_empty_payment_id exception; --Не задан id платежа
  pragma exception_init(e_empty_payment_id, c_error_code_empty_payment_id);
  --
  e_empty_status exception; --Не задан id платежа
  pragma exception_init(e_empty_status, c_error_code_empty_status);
  --
  e_empty_status_change_reason exception; --Не задана причина изменения платежа
  pragma exception_init(e_empty_status_change_reason, c_error_code_empty_status_change_reason);
  --
  e_payment_not_found exception; --Не найден платеж
  pragma exception_init(e_payment_not_found, c_error_code_payment_not_found);
  --
  e_payment_status_error exception; --Ошибка статуса платежа
  pragma exception_init(e_payment_status_error, c_error_code_status_error);
  --payment_detail:
  e_payment_delete_restriction exception; --Удаление платежей запрещено
  pragma exception_init(e_payment_delete_restriction, c_error_code_delete_restriction);
  --
  --payment_detail:
  e_payment_detail_api_restriction exception; --Внесение изменений в PAYMENT_DETAIL только через API
  pragma exception_init(e_payment_detail_api_restriction, c_error_code_payment_detail_api_restriction);
  --
  e_empty_payment_details exception; --Коллекция не содержит данных
  pragma exception_init(e_empty_payment_details, c_error_code_empty_payment_details);
  --
  e_empty_field_id exception; --ID поля не может быть пустым;
  pragma exception_init(e_empty_field_id, c_error_code_empty_field_id);
  --
  e_empty_field_value exception; --Значение в поле не может быть пустым;
  pragma exception_init(e_empty_field_value, c_error_code_empty_field_value);
  
  ----------------------------------------------------------------------------------------------------------------------
  --ПРОЦЕДУРЫ И ФУНКЦИИ:
  
  --Включить использование API
  procedure enable_api;

  --Выключить использование API
  procedure disable_api;
  
  --Получить флаг использования API
  function is_api return boolean;
  
end common_pack;