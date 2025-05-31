create or replace trigger payment_b_iu_tech_fields
  before insert or update
  on payment
  for each row
declare
  v_systimestamp timestamp := systimestamp;
begin
  if inserting then
    :new.create_dtime_tech := v_systimestamp;
  end if;

  :new.update_dtime_tech := v_systimestamp;
end;