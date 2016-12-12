function ds = PID(categSep,Kp,Ki,Kd,OptimalForget,maxIncrement)

%categSep is vector from 1:t with all the available categSep points
error = categSep-OptimalForget;
if length(error) == 1
    error = [0 error];
end
ds_temp = Kp*error(end) + Ki*sum(error) + Kd*(error(end)-error(end-1));
ds = min([abs(maxIncrement) abs(ds_temp)]) * sign(ds_temp);

end