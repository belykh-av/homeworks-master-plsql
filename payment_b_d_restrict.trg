create or replace trigger payment_b_d_restrict
  before delete
  on payment
  for each row
begin
  payment_api_pack.deleting_restriction;  
end;