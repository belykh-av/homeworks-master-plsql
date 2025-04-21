--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”

declare
  c_status_created constant number(10) := 0;
  v_message varchar2(4000 char) := 'Платеж создан.';
  v_current_dtime timestamp := systimestamp;
begin
  v_message := v_message || ' Статус: ' || c_status_created;
  dbms_output.put_line(to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--Сброс платежа в "ошибочный статус"
declare
  c_status_failed constant number(10) := 2;
  v_cause varchar2(4000 char) := 'недостаточно средств';
  v_message varchar2(4000 char)
    := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  v_current_dtime timestamp(6) := systimestamp;
begin
  v_message := v_message || ' Статус: ' || c_status_failed || '. Причина: ' || v_cause;
  dbms_output.put_line(to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--Отмена платежа
declare
  c_status_canceled constant number(10) := 3;
  v_cause varchar2(4000 char) := 'ошибка пользователя';
  v_message varchar2(4000 char) := 'Отмена платежа с указанием причины.';
  v_current_dtime timestamp(3) := systimestamp;
begin
  v_message := v_message || ' Статус: ' || c_status_canceled || '. Причина: ' || v_cause;
  dbms_output.put_line(to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--Успешное завершение платежа
declare
  c_status_completed constant number(10) := 1;
  v_message varchar2(4000 char) := 'Успешное завершение платежа.';
  v_current_dtime timestamp(2) := systimestamp;
begin
  v_message := v_message || ' Статус: ' || c_status_completed;
  dbms_output.put_line(
    to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--Данные платежа добавлены или обновлены
declare
  v_message varchar2(4000 char)
    := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_date timestamp(2) := sysdate;
begin
  dbms_output.put_line(to_char(v_current_date, 'DL HH:MI:SS:AM') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/

--Детали платежа удалены
declare
  v_message varchar2(4000 char) := 'Детали платежа удалены по списку id_полей';
  v_current_date timestamp(2) := sysdate;
begin
  dbms_output.put_line(to_char(v_current_date, 'YYYYMMHH_HH24MISS') || ':');
  dbms_output.put_line(v_message);
  dbms_output.put_line('');
end;
/