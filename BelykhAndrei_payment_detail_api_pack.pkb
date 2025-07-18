﻿CREATE OR REPLACE PACKAGE BODY payment_detail_api_pack is
  --Флаг использования API для венения изменений в таблицу payment_detail
  g_is_api boolean := false;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка на внесение изменений через API
  procedure api_restiction is
  begin
    --Проверка локального API срабатывает, если установлен глобальный API
    if common_pack.is_api and not g_is_api then
      raise_application_error(c_error_code_payment_detail_api_restriction,
                              c_error_message_payment_detail_api_restriction);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка коллекции деталей платежей.
  procedure check_payment_details(p_payment_details in t_payment_detail_array) is
  begin
    if p_payment_details is empty then
      raise e_empty_payment_details;
    end if;

    for i in p_payment_details.first .. p_payment_details.last loop
      if p_payment_details(i).field_id is null then
        raise e_empty_field_id;
      elsif p_payment_details(i).field_value is null then
        raise e_empty_field_value;
      end if;
    end loop;
  exception
    when e_empty_payment_details then
      raise_application_error(c_error_code_empty_payment_details, c_error_message_empty_payment_details);
    when e_empty_field_id then
      raise_application_error(c_error_code_empty_field_id, c_error_message_empty_field_id);
    when e_empty_field_value then
      raise_application_error(c_error_code_empty_field_value, c_error_message_empty_field_value);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Добавление деталей платежа
  procedure insert_payment_detail(p_payment_id in payment.payment_id%type,
                                  p_payment_details in t_payment_detail_array) is
  begin
    g_is_api := true;

    --Проверить и заблокировать платеж
    payment_api_pack.try_lock_payment(p_payment_id);

    insert into payment_detail(payment_id, field_id, field_value)
      select p_payment_id, pd.field_id, pd.field_value
      from table(p_payment_details) pd;

    g_is_api := false;
  exception
    when others then
      g_is_api := false;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Данные платежа добавлены или обновлены.
  procedure insert_or_update_payment_detail(p_payment_id in payment.payment_id%type,
                                            p_payment_details in t_payment_detail_array) is
  begin
    --Провека коллекци
    check_payment_details(p_payment_details);

    --Проверить и заблокировать платеж
    payment_api_pack.try_lock_payment(p_payment_id);

    g_is_api := true;

    --Изменение данных платежа
    merge into payment_detail a
    using (select value(c).field_id as field_id, value(c).field_value as field_value
           from table(p_payment_details) c) b
    on (b.field_id = a.field_id and a.payment_id = p_payment_id)
    when matched then
      update set a.field_value = b.field_value
    when not matched then
      insert (a.payment_id, a.field_id, a.field_value)
      values (p_payment_id, b.field_id, b.field_value);

    g_is_api := false;
  exception
    when others then
      g_is_api := false;
      raise;
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --Детали платежа удалены.
  procedure delete_payment_detail(p_payment_id in payment.payment_id%type,
                                  p_payment_detail_field_ids in t_number_array) is
    v_deleted_field_ids t_number_array := t_number_array(); --Коллекция удаленных деталей платежа
  begin
    --Проверить и заблокировать платеж
    payment_api_pack.try_lock_payment(p_payment_id);

    g_is_api := true;

    delete from payment_detail
    where payment_id = p_payment_id and field_id in (select column_value from table(p_payment_detail_field_ids))
    returning field_id
    bulk collect into v_deleted_field_ids;

    g_is_api := false;
  exception
    when others then
      g_is_api := false;
      raise;
  end;
end;
/
