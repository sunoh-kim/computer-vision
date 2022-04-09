function res = LevenbergMarquardt(model,x,x_t,tolerance,n,regular)

x_t=x_t(:);
x=x(:);
J=jacobian(model,x);
a=1;
J0=double(subs(J,x,x_t));
r0=double(subs(model,x,x_t));
x_t=x_t-inv((J0'*J0+regular*diag(diag(J0'*J0))))*J0'*r0;

while (norm(J0'*r0)>tolerance)
    J0=double(subs(J,x,x_t));
    r0=double(subs(model,x,x_t));
    x_t=x_t-inv((J0'*J0+regular*diag(diag(J0'*J0))))*J0'*r0;
    a=a+1;
    disp(r0)
    if a>n break;
    end
end

res=x_t;

end
