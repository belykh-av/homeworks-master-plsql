--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
--21.04.2025. Изменено с учетом задания №5 ("Условия").
--22.04.2025. Изменено с учетом задания №6 ("Модификаторы %type и %rowtype") и c учетом замечаний по заданию 5.
--29.04.2025. Изменено с учетом задания №9 ("Коллекции").
--            В блоки "1.Создание платежа" и "5.Данные платежа добавлены или обновлены" добавлена переменная типа t_payment_detail_array.
--            В блок "6.Детали платежа удалены" добавлена переменная типа t_number_array.

--1.Создание платежа.
declare
  c_status_created constant payment.status%type := 0;
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_payment_id payment.payment_id%type := null;
  v_current_dtime timestamp := systimestamp;
  v_message varchar2(100 char);
  v_payment_details t_payment_detail_array := t_payment_detail_array(); --Детали платежа
begin
  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF'));
  v_message := 'Платеж создан. ' || 'Статус: ' || c_status_created;
  dbms_output.put_line(v_message);
  dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  v_payment_details.extend();
  v_payment_details(1) := t_payment_detail(c_payment_detail_field_id_client_software, 'Онлайн банк');
  v_payment_details.extend();
  v_payment_details(2) := t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2');
  v_payment_details.extend();
  v_payment_details(3) := t_payment_detail(c_payment_detail_field_id_note, 'Просто перевод');
  dbms_output.put_line('');
end;
/

--2.Сброс платежа в "ошибочный статус".
declare
  c_status_failed constant payment.status%type := 2;
  v_payment_id payment.payment_id%type := 222;
  v_status_change_reason payment.status_change_reason%type := 'недостаточно средств';
  v_current_dtime timestamp(6) := systimestamp;
  v_message varchar2(100 char);
begin
  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6'));

  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    v_message := 'Сброс платежа в "ошибочный статус" с указанием причины. ' ||
                 ('Статус: ' || c_status_failed || '. ')||
                 ('Причина: ' || v_status_change_reason);
    dbms_output.put_line(v_message);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line('');
end;
/

--3.Отмена платежа.
declare
  c_status_canceled constant payment.status%type := 3;
  v_payment_id payment.payment_id%type := 333;
  v_status_change_reason payment.status_change_reason%type := 'ошибка пользователя';
  v_current_dtime timestamp(3) := systimestamp;
  v_message varchar2(100 char);
begin
  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3'));

  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    v_message := 'Отмена платежа с указанием причины. ' ||
                 ('Статус: ' || c_status_canceled || '. ')||
                 ('Причина: ' || v_status_change_reason);
    dbms_output.put_line(v_message);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line('');
end;
/

--4.Успешное завершение платежа.
declare
  c_status_completed constant payment.status%type := 1;
  v_payment_id payment.payment_id%type := 444;
  v_current_dtime timestamp(2) := systimestamp;
  v_message varchar2(100 char) := 'Успешное завершение платежа.';
begin
  dbms_output.put_line(
    'Дата операции: ' ||
    to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS'));

  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    v_message := 'Успешное завершение платежа. ' || 'Статус: ' || c_status_completed;

    dbms_output.put_line(v_message);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line('');
end;
/

--5.Данные платежа добавлены или обновлены.
declare
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_payment_id payment.payment_id%type := 555;
  v_current_date timestamp(2) := sysdate;
  v_message varchar2(100 char);
  v_payment_details t_payment_detail_array := t_payment_detail_array(); --Детали платежа
begin
  dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'DL HH:MI:SS:AM'));

  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    v_message := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
    dbms_output.put_line(v_message);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));

    v_payment_details.extend();
    v_payment_details(1) := t_payment_detail(c_payment_detail_field_id_note,
                                             'Изменение данных платежа');
    v_payment_details.extend();
    v_payment_details(2) := t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2');
    v_payment_details.extend();
    v_payment_details(3) := t_payment_detail(c_payment_detail_field_id_client_software, 'web-клиент');
    v_payment_details.extend();
  end if;

  dbms_output.put_line('');
end;
/

--6.Детали платежа удалены.
declare
  v_payment_id payment.payment_id%type := null;
  v_current_date timestamp(2) := sysdate;
  v_message varchar2(100 char);
  v_payments t_number_array := t_number_array();
begin
  dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));

  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    v_message := 'Детали платежа удалены по списку id_полей';

    dbms_output.put_line(v_message);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));

    v_payments.extend();
    v_payments(v_payments.last) := v_payment_id;
  end if;

  dbms_output.put_line('');
end;
/