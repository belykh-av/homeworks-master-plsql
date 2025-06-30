CREATE OR REPLACE PACKAGE payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по деталям платежа
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  -- 25.05.2025. ДЗ14. Добавлены исключения.
  -- 31.05.2025. ДЗ15. Добавлен флаг использования API и запрет на прямые DML-операции с таблицей PAYMENT_DETAIL.
  -- 04.06.2025. ДЗ16. Константы и исключения перенесены в COMMON_PAСK. Убраны лишние переменные и вывод в output.
  -- 29.06.2025. ДЗ19. По замечаниям перенес сюда из COMMON_PACK константы и исключения, касающиеся API PAYMENT_DETAIL
  --
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"

  --Коды ошибок:
  c_error_code_payment_detail_api_restriction constant number := -20200;
  c_error_code_empty_payment_details constant number := -20201;
  c_error_code_empty_field_id constant number := -20202;
  c_error_code_empty_field_value constant number := -20203;

  --Сообщения об ошибках:
  c_error_message_payment_detail_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицу PAYMENT_DETAIL можно вносить только через API' ;
  c_error_message_empty_payment_details constant varchar2(100 char)
    := 'Коллекция не содержит данных' ;
  c_error_message_empty_field_id constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_message_empty_field_value constant varchar2(100 char)
    := 'Значение в поле не может быть пустым' ;

   ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  --
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
  --

  ---------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:

  --Проверка на внесение изменений через API
  procedure api_restiction;

  --Проверка коллекции деталей платежей
  procedure check_payment_details(p_payment_details in t_payment_detail_array);

  --Добавление деталей платежа
  procedure insert_payment_detail(p_payment_id in payment.payment_id%type, p_payment_details in t_payment_detail_array);

  --Данные платежа добавлены или обновлены
  procedure insert_or_update_payment_detail(p_payment_id in payment.payment_id%type,
                                            p_payment_details in t_payment_detail_array);

  --Детали платежа удалены
  procedure delete_payment_detail(p_payment_id in payment.payment_id%type,
                                  p_payment_detail_field_ids in t_number_array);
end;
/
