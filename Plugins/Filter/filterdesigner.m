
function [b a]=filterdesigner(fs,fg,param,type,dBgain)
% function to design typical EQ filter used in audio processing
% implementation of the EQ cookbook from Robert Bristow Johnson
% USAGE: [b a]=filterdesigner(fs,fg,param,type,dBgain)
% INput:
%    fs: Sampling rate
%    fg: working frequency
%    param: Q, or Slope, Boct, depends on the design
%    type: Design routine possible values are
%          'LP','HP','BP1','BP2','notch','AP' allpass,'pEQ','LS'
%          lowshelv,'HS' highshelv
% Output:
%    [b, a]: coefficients for the final
% Example:

% Author: Andreas Volgenandt (Joerg Bitzer (documentation and some functions), Jade HS, IHA)
% No copyrights or -lefts attached (public domain)

w0=2*pi*fg/fs;
Q=param;
alpha=sin(w0)/(2*Q);

if nargin<5
    dBgain=-10;
end

switch type
    
    case 'LP'
        btemp=(1-cos(w0));
        
        b(1)=btemp/2;
        b(2)=b(1)*2;
        b(3)=b(1);
        a(1)=1+alpha;
        a(2)=-2*cos(w0);
        a(3)=1-alpha;

    case 'HP'
        btemp=(1+cos(w0));
        
        b(1)=btemp/2;
        b(2)=-b(1)*2;
        b(3)=b(1);
        a(1)=1+alpha;
        a(2)=-2*cos(w0);
        a(3)=1-alpha;
        
    case 'BP1'
        
        b(1)=Q*alpha;
        b(2)=0;
        b(3)=-b(1);
        a(1)=1+alpha;
        a(2)=-2*cos(w0);
        a(3)=1-alpha;
        
    case 'BP2'
        
        b(1)=alpha;
        b(2)=0;
        b(3)=-b(1);
        a(1)=1+alpha;
        a(2)=-2*cos(w0);
        a(3)=1-alpha;
        
    case 'notch'
        
        b(1)=1;
        b(2)=-2*cos(w0);
        b(3)=1;
        a(1)=1+alpha;
        a(2)=b(2);
        a(3)=1-alpha;
        
    case 'AP'
        
        b(1)=1-alpha;
        b(2)=-2*cos(w0);
        b(3)=1+alpha;
        a(1)=b(3);
        a(2)=b(2);
        a(3)=b(1);
    case 'pEQ'
        A=10^(dBgain/40);
        b(1)=1+alpha*A;
        b(2)=-2*cos(w0);
        b(3)=1-alpha*A;
        a(1)=1+alpha/A;
        a(2)=b(2);
        a(3)=1-alpha/A;
    case 'LS'
        A=10^(dBgain/40);
        
        b(1)=A*  ((A+1)-(A-1)*cos(w0)+2*sqrt(A)*alpha);
        b(2)=2*A*((A-1)-(A+1)*cos(w0));
        b(3)=A*  ((A+1)-(A-1)*cos(w0)-2*sqrt(A)*alpha);
        a(1)=     (A+1)+(A-1)*cos(w0)+2*sqrt(A)*alpha;
        a(2)=-2* ((A-1)+(A+1)*cos(w0));
        a(3)=     (A+1)+(A-1)*cos(w0)-2*sqrt(A)*alpha;
    case 'HS'
        A=10^(dBgain/40);
        
        b(1)=A*((A+1)+(A-1)*cos(w0)+2*sqrt(A)*alpha);
        b(2)=-2*A*((A-1)+(A+1)*cos(w0));
        b(3)=A*((A+1)+(A-1)*cos(w0)-2*sqrt(A)*alpha);
        a(1)=((A+1)-(A-1)*cos(w0)+2*sqrt(A)*alpha);
        a(2)=2*((A-1)-(A+1)*cos(w0));
        a(3)=((A+1)-(A-1)*cos(w0)-2*sqrt(A)*alpha);
        
    otherwise
        b=1;
        a=1;
end

%Normalisieren (a(1)=1)
b=b./a(1);
a=a./a(1);
