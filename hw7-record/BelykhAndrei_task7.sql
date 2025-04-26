--Автор: Белых Андрей
--Задание номер 7 - Record
--25.04.2025. Этот файл не входит в основное задание курса по созданию API.
--26.04.2025. Переделано по замечаниям. Обнулена переменная v_reс_1, а не ее поле v_rec_1.name

declare
  type t_rec is record(id number(12),
                       created_date date not null:= sysdate,
                       name varchar2(50 char):= 'Имя по умолчанию');

  v_rec_1 t_rec;
  v_rec_2 t_rec;
  v_payment_detail_field payment_detail_field%rowtype;
begin
  v_rec_1.id := 1;
  v_rec_2.id := 2;

  dbms_output.put_line(
    'record 1: ' ||
    ('id=' || to_number(v_rec_1.id) || '; ')||
    ('created=' || to_char(v_rec_1.created_date, 'DD.MM.YYYY HH24:MI:SS') || '; ')||
    ('name="' || v_rec_1.name || '"'));

  dbms_output.put_line(
    'record 2: ' ||
    ('id=' || to_number(v_rec_2.id) || '; ')||
    ('created=' || to_char(v_rec_2.created_date, 'DD.MM.YYYY HH24:MI:SS') || '; ')||
    ('name="' || v_rec_2.name || '"'));

  v_rec_1 := null;

  dbms_output.put_line(
    'record 1: ' ||
    case
      when v_rec_1.id is null and v_rec_1.created_date is null and v_rec_1.name is null then 'It''s null'
      else 'It''s not null'
    end);

  dbms_output.put_line(
    'record 2: ' ||
    case
      when v_rec_2.id is null and v_rec_2.created_date is null and v_rec_2.name is null then 'It''s null'
      else 'It''s not null'
    end);

  select *
  into v_payment_detail_field
  from payment_detail_field
  where rownum = 1;

  dbms_output.put_line(
    'payment_detail_field: ' ||
    ('filed_id=' || to_char(v_payment_detail_field.field_id) || '; ')||
    ('name="' || v_payment_detail_field.name || '"; ')||
    ('deccription="' || v_payment_detail_field.description || '"'));
end;
/