create or replace package payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по деталям платежа
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  -- 25.05.2025. ДЗ14. Добавлены исключения.
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"

  --Коды ошибок: 
  c_error_code_empty_payment_details constant number := -20201;
  c_error_code_empty_field_id constant number := -20202;
  c_error_code_empty_field_value constant number := -20203;

  --Сообщения об ошибках: 
  c_error_message_empty_payment_details constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_message_empty_field_id constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_message_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
    
  ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  e_empty_payment_details exception; --Коллекция не содержит данных
  pragma exception_init(e_empty_payment_details, c_error_code_empty_payment_details);
  -- 
  e_empty_field_id exception; --ID поля не может быть пустым;
  pragma exception_init(e_empty_field_id, c_error_code_empty_field_id);
  --
  e_empty_field_value exception; --Значение в поле не может быть пустым;
  pragma exception_init(e_empty_field_value, c_error_code_empty_field_value);
  
  ----------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:

  --Проверка коллекции деталей платежей.
  procedure check_payment_details(p_payment_details t_payment_detail_array);

  --Данные платежа добавлены или обновлены.
  procedure insert_or_update_payment_detail(p_payment_id payment.payment_id%type,
                                            p_payment_details t_payment_detail_array);

  --Детали платежа удалены.
  procedure delete_payment_detail(p_payment_id payment.payment_id%type, p_payment_detail_field_ids t_number_array);
end;