create or replace package payment_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по платежу
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  --
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --Статус платежа:
  c_status_created constant payment.status%type := 0; --Создан
  c_status_completed constant payment.status%type := 1; --Проведен
  c_status_failed constant payment.status%type := 2; --Ошибка проведения
  c_status_canceled constant payment.status%type := 3; --Отмена платежа

  --Валюта:
  c_currency_rub constant currency.currency_id%type := 643; --Российский рубль
  c_currency_usd constant currency.currency_id%type := 840; --Доллар США
  c_currency_eur constant currency.currency_id%type := 978; --Евро

  --Статус изменения платежа:
  c_status_change_reason_no_money constant payment.status_change_reason%type
    := 'недостаточно средств' ;
  c_status_change_reason_user_error constant payment.status_change_reason%type
    := 'ошибка пользователя' ;

  ---------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:

  --Проверка наличия платежа в базе данных, в зависимости от его статуса (опционально)
  --Возвращает: true - платеж существует, false - платеж не существует (ошибка при этом выводится в буфер)
  function check_payment_exists(p_payment_id payment.payment_id%type, p_status payment.status%type := null)
    return boolean;

  --Создание платежа.
  function create_payment(p_create_dtime payment.create_dtime%type,
                          p_from_client_id payment.from_client_id%type,
                          p_to_client_id payment.to_client_id%type,
                          p_summa payment.summa%type,
                          p_currency_id payment.currency_id%type := c_currency_rub,
                          p_payment_details t_payment_detail_array)
    return payment.payment_id%type;

  --Сброс платежа в "ошибочный статус".
  procedure fail_payment(p_payment_id payment.payment_id%type,
                         p_status_change_reason payment.status_change_reason%type := c_status_change_reason_no_money);

  --Отмена платежа.
  procedure cancel_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := c_status_change_reason_user_error);

  --Успешное завершение платежа.
  procedure successful_finish_payment(p_payment_id payment.payment_id%type);
end;