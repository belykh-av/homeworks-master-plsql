create or replace package payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по деталям платежа
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  --
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"

  ----------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:

  --Проверка коллекции деталей платежей.
  --Возвращает: true - если коллекция корректная, false - коллекция сожержит ошибки (выводятся в буфер).
  function check_payment_details(p_payment_details t_payment_detail_array)
    return boolean;

  --Данные платежа добавлены или обновлены.
  procedure insert_or_update_payment_detail(p_payment_id payment.payment_id%type,
                                            p_payment_details t_payment_detail_array);

  --Детали платежа удалены.
  procedure delete_payment_detail(p_payment_id payment.payment_id%type, p_payment_detail_field_ids t_number_array);
end;