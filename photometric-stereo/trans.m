function res=trans(in)

narginchk(1,2);
if min(size(in))==1
    if size(in,2)>1
        do_trans = 1;
    else
        do_trans = 0;
    end
    
    in = in(:);
else
    do_trans = 0;
    
end

n = size(in,1);

m = size(in,2);

if (size(in,1)<n)
    aa = zeros(n,m); aa(1:size(in,1),:) = in;
else
    aa = in(1:n,:);
end

y=zeros(2*(n+1),m); y(2:n+1,:)=aa; y(n+3:2*(n+1),:)=-flipud(aa);
yy=fft(y); res=yy(2:n+1,:)/(-2*sqrt(-1));

if (isreal(in))
    res = real(res);
end
if (do_trans)
    res = res.';
end