create or replace package body payment_detail_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Проверка коллекции деталей платежей.
  procedure check_payment_details(p_payment_details t_payment_detail_array) is
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
  --Данные платежа добавлены или обновлены.
  procedure insert_or_update_payment_detail(p_payment_id payment.payment_id%type,
                                            p_payment_details t_payment_detail_array) is
    v_current_date timestamp(2) := sysdate; --Дата операции
  begin
    --Проверка наличия платежа в базе данных
    payment_api_pack.check_payment_exists(p_payment_id);

    --Провека коллекци и на пустые поля коллекции
    check_payment_details(p_payment_details);

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

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'DL HH:MI:SS:AM'));
    dbms_output.put_line(
      'Данные платежа добавлены или обновлены по списку id_поля/значение');
    dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --6.Детали платежа удалены.
  procedure delete_payment_detail(p_payment_id payment.payment_id%type, p_payment_detail_field_ids t_number_array) is
    v_current_date timestamp(2) := sysdate; --Дата операции
    v_deleted_field_ids t_number_array := t_number_array(); --Коллекция удаленных деталей платежа
  begin
    --Проверка наличия платежа в базе данных
    payment_api_pack.check_payment_exists(p_payment_id);

    delete from payment_detail
    where payment_id = p_payment_id and field_id in (select column_value from table(p_payment_detail_field_ids))
    returning field_id
    bulk collect into v_deleted_field_ids;

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));
    dbms_output.put_line('Детали платежа удалены по списку id_полей');
    dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
    dbms_output.put_line('Кол-во удаленных полей: ' || to_char(v_deleted_field_ids.count));
  end;
end;