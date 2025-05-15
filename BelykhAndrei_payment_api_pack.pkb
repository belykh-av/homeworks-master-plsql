create or replace package body payment_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Проверка наличия платежа в базе данных, в зависимости от его статуса (опционально)
  --Возвращает: true - платеж существует, false - платеж не существует (ошибка при этом выводится в буфер)
  function check_payment_exists(p_payment_id payment.payment_id%type, p_status payment.status%type := null)
    return boolean is
    v_payment_id payment.payment_id%type;
  begin
    if p_payment_id is null then
      --Пустой ID платежа
      dbms_output.put_line('ОШИБКА! Не задан ID платежа для проверки');
      return false;
    elsif p_status is null then
      --Проверка наличия платежа
      select max(payment_id)
      into v_payment_id
      from payment
      where payment_id = p_payment_id;

      if v_payment_id is null then
        dbms_output.put_line('ОШИБКА! Платеж ID=' || to_char(p_payment_id) || ' не найден');
        return false;
      end if;
    else
      --Проверка наличия платежа с заданным статусом
      select max(payment_id)
      into v_payment_id
      from payment
      where payment_id = p_payment_id and status = p_status;

      if v_payment_id is null then
        dbms_output.put_line(
          'ОШИБКА! Платеж ID=' ||
          to_char(p_payment_id)||
          ' не найден или находится не в статусе ' ||
          to_char(p_status));
        return false;
      end if;
    end if;

    return true;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа.
  function create_payment(p_create_dtime payment.create_dtime%type,
                          p_from_client_id payment.from_client_id%type,
                          p_to_client_id payment.to_client_id%type,
                          p_summa payment.summa%type,
                          p_currency_id payment.currency_id%type := c_currency_rub,
                          p_payment_details t_payment_detail_array)
    return payment.payment_id%type is
    v_payment_id payment.payment_id%type := null; --ID созданного платежа
    v_current_dtime timestamp := systimestamp; --Дата операции
    v_is_error boolean := false; --Флаг ошибки проверки данных платежа
  begin
    --Провека коллекции деталей платежа с установкой флага ошибки
    v_is_error := not payment_detail_api_pack.check_payment_details(p_payment_details);

    --Создание платежа, если нет флага ошибки
    if not v_is_error then
      insert into payment(payment_id, create_dtime, summa, currency_id, from_client_id, to_client_id, status)
        values (
                 payment_seq.nextval,
                 p_create_dtime,
                 p_summa,
                 p_currency_id,
                 p_from_client_id,
                 p_to_client_id,
                 c_status_created)
      returning payment_id
      into v_payment_id;

      --Создание деталей платежа
      insert into payment_detail(payment_id, field_id, field_value)
        select v_payment_id, pd.field_id, pd.field_value
        from table(p_payment_details) pd;

      --Сообщение об операции
      dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF'));
      dbms_output.put_line('Платеж создан. ' || 'Статус: ' || c_status_created);
      dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
    else
      dbms_output.put_line('Ошибка создания платежа');
    end if;

    dbms_output.put_line('');
    return v_payment_id;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус".
  procedure fail_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := c_status_change_reason_no_money) is
    v_current_dtime timestamp(6) := systimestamp; --Дата операции
  begin
    if p_payment_id is null then
      dbms_output.put_line('ID объекта не может быть пустым');
    elsif p_status_change_reason is null then
      dbms_output.put_line('Причина не может быть пустой');
    else
      update payment
      set status = c_status_failed, status_change_reason = p_status_change_reason
      where payment_id = p_payment_id and status = c_status_created;

      if sql%rowcount = 0 then
        dbms_output.put_line(
          'Платеж ID=' ||
          to_char(p_payment_id)||
          ' не найден или находится не в статусе "Платеж создан"' ||
          c_status_created);
      else
        dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6'));
        dbms_output.put_line(
          'Сброс платежа в "ошибочный статус" с указанием причины. ' ||
          ('Статус: ' || c_status_failed || '. ')||
          ('Причина: ' || p_status_change_reason));
        dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
      end if;
    end if;

    dbms_output.put_line('');
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --Отмена платежа.
  procedure cancel_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := c_status_change_reason_user_error) is
    v_current_dtime timestamp(3) := systimestamp; --Дата операции
  begin
    if p_payment_id is null then
      dbms_output.put_line('ID объекта не может быть пустым');
    elsif p_status_change_reason is null then
      dbms_output.put_line('Причина не может быть пустой');
    else
      update payment
      set status = c_status_canceled, status_change_reason = p_status_change_reason
      where payment_id = p_payment_id and status = c_status_created;

      if sql%rowcount = 0 then
        dbms_output.put_line(
          'Платеж ID=' ||
          to_char(p_payment_id)||
          ' не найден или находится не в статусе "Платеж создан"' ||
          c_status_created);
      else
        dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3'));
        dbms_output.put_line(
          'Отмена платежа с указанием причины. ' ||
          ('Статус: ' || c_status_canceled || '. ')||
          ('Причина: ' || p_status_change_reason));
        dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
      end if;
    end if;

    dbms_output.put_line('');
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа.
  procedure successful_finish_payment(p_payment_id payment.payment_id%type) is
    v_current_dtime timestamp(2) := systimestamp; --Дата операции
  begin
    if p_payment_id is null then
      dbms_output.put_line('ID объекта не может быть пустым');
    else
      update payment
      set status = c_status_completed
      where payment_id = p_payment_id and status = c_status_created;

      if sql%rowcount = 0 then
        dbms_output.put_line(
          'Платеж ID=' ||
          to_char(p_payment_id)||
          ' не найден или находится не в статусе "Платеж создан"' ||
          c_status_created);
      else
        dbms_output.put_line(
          'Дата операции: ' ||
          to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS'));

        dbms_output.put_line(
          'Успешное завершение платежа. ' || 'Статус: ' || c_status_completed);
        dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
      end if;
    end if;

    dbms_output.put_line('');
  end;
end;