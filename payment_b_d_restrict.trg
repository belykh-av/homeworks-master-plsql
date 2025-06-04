create or replace trigger payment_b_d_restrict
  before delete
  on payment
  for each row
begin
  if common_pack.is_api then
    payment_api_pack.check_delete;
  end if;
end;