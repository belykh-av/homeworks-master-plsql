create or replace package body payment_detail_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Проверка коллекции деталей платежей.
  --Возвращает: true - если коллекция корректная, false - коллекция сожержит ошибки (выводятся в буфер).
  function check_payment_details(p_payment_details t_payment_detail_array)
    return boolean is
    v_result boolean := true;
  begin
    --Провека коллекции деталей платежа с установкой флага ошибки
    if p_payment_details is empty then
      dbms_output.put_line('ОШИБКА! Коллекция не содержит данных');
      v_result := false;
    else
      for i in p_payment_details.first .. p_payment_details.last loop
        if p_payment_details(i).field_id is null then
          dbms_output.put_line('ОШИБКА! Элемент коллекции №' || to_char(i) || ':');
          dbms_output.put_line('ОШИБКА! ID поля не может быть пустым');
          v_result := false;
        elsif p_payment_details(i).field_value is null then
          dbms_output.put_line('ОШИБКА! Элемент коллекции №' || to_char(i) || ':');
          dbms_output.put_line('ОШИБКА! Значение в поле не может быть пустым');
          v_result := false;
        end if;
      end loop;
    end if;

    return v_result;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Данные платежа добавлены или обновлены.
  procedure insert_or_update_payment_detail(p_payment_id payment.payment_id%type,
                                            p_payment_details t_payment_detail_array) is
    v_current_date timestamp(2) := sysdate; --Дата операции
  begin
    --Проверка задания платежа и наличия его в базе
    if payment_api_pack.check_payment_exists(p_payment_id) then
      --Провека коллекци и на пустые поля коллекции
      if check_payment_details(p_payment_details) then
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
      end if;
    end if;

    dbms_output.put_line('');
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --6.Детали платежа удалены.
  procedure delete_payment_detail(p_payment_id payment.payment_id%type, p_payment_detail_field_ids t_number_array) is
    v_current_date timestamp(2) := sysdate; --Дата операции
    v_deleted_field_ids t_number_array := t_number_array(); --Коллекция удаленных деталей платежа
  begin
    --Проверка задания платежа и наличия его в базе
    if payment_api_pack.check_payment_exists(p_payment_id) then
      delete from payment_detail
      where payment_id = p_payment_id and field_id in (select column_value from table(p_payment_detail_field_ids))
      returning field_id
      bulk collect into v_deleted_field_ids;

      dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));
      dbms_output.put_line('Детали платежа удалены по списку id_полей');
      dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
      dbms_output.put_line('Кол-во удаленных полей: ' || to_char(v_deleted_field_ids.count));
    end if;

    dbms_output.put_line('');
  end;
end;