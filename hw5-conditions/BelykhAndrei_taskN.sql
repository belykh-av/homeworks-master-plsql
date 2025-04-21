--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
--21.04.2025. Изменено с учетом задания №5 ("Условия").

--1. Создание платежа.
declare
  c_status_created constant number(10) := 0;
  v_current_dtime timestamp := systimestamp;
  v_payment_id number(38) := 111;
  v_message varchar2(100 char);
begin
  v_message := 'Платеж создан. ' || 'Статус: ' || c_status_created;
  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF'));
  dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--2. Сброс платежа в "ошибочный статус".
declare
  c_status_failed constant number(10) := 2;
  v_current_dtime timestamp(6) := systimestamp;
  v_payment_id number(38) := 222;
  v_cause varchar2(50 char) := 'недостаточно средств';
  v_message varchar2(100 char);
begin
  v_message := case
                 when v_payment_id is null then
                   'ID объекта не может быть пустым'
                 when v_cause is null then
                   'Причина не может быть пустой'
                 else
                   'Сброс платежа в "ошибочный статус" с указанием причины. ' ||
                   ('Статус: ' || c_status_failed || '. ')||
                   ('Причина: ' || v_cause)
               end;

  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6'));

  if v_payment_id is not null then
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--3. Отмена платежа.
declare
  c_status_canceled constant number(10) := 3;
  v_current_dtime timestamp(3) := systimestamp;
  v_payment_id number(38) := 333;
  v_cause varchar2(50 char) := 'ошибка пользователя';
  v_message varchar2(100 char);
begin
  v_message := case
                 when v_payment_id is null then
                   'ID объекта не может быть пустым'
                 when v_cause is null then
                   'Причина не может быть пустой'
                 else
                   'Отмена платежа с указанием причины. ' ||
                   ('Статус: ' || c_status_canceled || '. ')||
                   ('Причина: ' || v_cause)
               end;

  dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3'));

  if v_payment_id is not null then
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--4. Успешное завершение платежа.
declare
  c_status_completed constant number(10) := 1;
  v_current_dtime timestamp(2) := systimestamp;
  v_payment_id number(38) := 444;
  v_message varchar2(100 char) := 'Успешное завершение платежа.';
begin
  v_message := case
                 when v_payment_id is null then 'ID объекта не может быть пустым'
                 else 'Успешное завершение платежа. ' || 'Статус: ' || c_status_completed
               end;
  dbms_output.put_line(
    'Дата операции: ' ||
    to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS'));

  if v_payment_id is not null then
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--5. Данные платежа добавлены или обновлены.
declare
  v_current_date timestamp(2) := sysdate;
  v_payment_id number(38) := 555;
  v_message varchar2(100 char);
begin
  v_message := case
                 when v_payment_id is null then
                   'ID объекта не может быть пустым'
                 else
                   'Данные платежа добавлены или обновлены по списку id_поля/значение'
               end;
  dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'DL HH:MI:SS:AM'));

  if v_payment_id is not null then
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--6. Детали платежа удалены.
declare
  v_current_date timestamp(2) := sysdate;
  v_payment_id number(38) := null;
  v_message varchar2(100 char);
begin
  v_message := case
                 when v_payment_id is null then 'ID объекта не может быть пустым'
                 else 'Детали платежа удалены по списку id_полей'
               end;
  dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));

  if v_payment_id is not null then
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/