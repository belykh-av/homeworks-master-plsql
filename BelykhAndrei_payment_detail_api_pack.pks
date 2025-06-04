create or replace package payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по деталям платежа
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  -- 25.05.2025. ДЗ14. Добавлены исключения.
  -- 31.05.2025. ДЗ15. Добавлен флаг использования API и запрет на прямые DML-операции с таблицей PAYMENT_DETAIL.
  -- 04.06.2025. ДЗ16. Константы и исключения перенесены в COMMON_PAСK. Убраны лишние переменные и вывод в output.
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