declare
  v_timer number;

  --Проверка через обработку исключения
  function is_payment_exists_ndf(p_payment_id payment.payment_id%type)
    return boolean is
    v number;
  begin
    select 1
    into v
    from payment
    where payment_id = p_payment_id;

    return true;
  exception
    when no_data_found then
      return false;
  end;
  
  --Проверка через select into
  function is_payment_exists_sel(p_payment_id payment.payment_id%type)
    return boolean is
    v number;
  begin
    select max(payment_id)
    into v
    from payment
    where payment_id = p_payment_id;

    if v is not null then
      return true;
    else
      return false;
    end if;
  end;

  --Проверка через курсор
  function is_payment_exists_cur(p_payment_id payment.payment_id%type)
    return boolean is
  begin
    for r in (select 1
              from payment
              where payment_id = p_payment_id
              having count(1) = 0) loop
      return false;
    end loop;

    return true;
  end;
begin
  --1.NO_DATA_FOUND
  v_timer := dbms_utility.get_time();

  for r in 1 .. 1e7 loop
    if is_payment_exists_ndf(r) then
      dbms_output.put_line(r || ' exists');
    end if;
  end loop;

  dbms_output.put_line('NDF elapsed seconds: ' || (dbms_utility.get_time() - v_timer) / 100);

  --2.SELECT_INTO
  v_timer := dbms_utility.get_time();

  for r in 1 .. 1e7 loop
    if is_payment_exists_sel(r) then
      dbms_output.put_line(r || ' exists');
    end if;
  end loop;
  
  dbms_output.put_line('SEL elapsed seconds: ' || (dbms_utility.get_time() - v_timer) / 100);

  --3.CURSOR 
  v_timer := dbms_utility.get_time();

  for r in 1 .. 1e7 loop
    if is_payment_exists_cur(r) then
      dbms_output.put_line(r || ' exists');
    end if;
  end loop;

  dbms_output.put_line('CUR elapsed seconds: ' || (dbms_utility.get_time() - v_timer) / 100);
end;
/*  РЕЗУЛЬТАТЫ для 10 млн. проверок
1 exists
6 exists
7 exists
9 exists
10 exists
11 exists
12 exists
13 exists
14 exists
42 exists
49 exists
50 exists
NDF elapsed seconds: 121,61
1 exists
6 exists
7 exists
9 exists
10 exists
11 exists
12 exists
13 exists
14 exists
42 exists
49 exists
50 exists
SEL elapsed seconds: 82,76
1 exists
6 exists
7 exists
9 exists
10 exists
11 exists
12 exists
13 exists
14 exists
42 exists
49 exists
50 exists
CUR elapsed seconds: 108,47
*/
