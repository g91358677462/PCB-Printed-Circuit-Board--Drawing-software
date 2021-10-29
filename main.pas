// 主要定義四個資料型態
type
	Tcircle=record //圓形資料型態
		d:double; //直徑
	end;
	
	Trectangle=record //方形資料型態
		w,h:double; //寬，高
	end;
	
	TApdef=record //Aperture 資料型態
		adCode:byte; //Aperture 編號
		tp:char; //圖形
		rec:Trectangle; //方形資料
		cir:Tcircle; //圓形資料
	end;
 
	Padptr=^Tpad; //指著 Pad 資料型態的指標
	
	Tpad=record //Pad 資料型態
		DorC:char; //正片還是負片
		AD:word; //用的 Aperture 編號
		x,y:double; //圖形中心座標
		next:Padptr; //Linked-List 的鏈結指向 Pad 資料型態
	end;
	
	Lineptr=^Tline; //指著 Line 資料型態的指標

	Tline=record //Line 資料型態
		DorC:char; //正片還是負片
		AD:word; //用的 Aperture 編號
		x1,y1,x2,y2:double; //一條線的起點與終點座標
		next:Lineptr; //Linked-List 的鏈結指向 Line 資料型態
	end;

	Drawptr=^TDraw; //指著畫圖資料型態指標
	
	TDraw=record //畫圖資料型態
		PorL:char; //畫 Pad 還畫 Line

	Padfrom:Padptr; //指著 Pad 資料型態的指標(起始)
	Padto:Padptr; //指著 Pad 資料型態的指標(結束)
	Linefrom:Lineptr; //指著 Line 資料型態的指標(起始)
	Lineto:Lineptr; //指著 Line 資料型態的指標(結束)
	next:Drawptr; //Linked-List 的鏈結指向畫圖資料型態
end;

// 讀檔程式
// 此段程式功用是把檔案裡的每一句字串放到型態同為字串型態的陣列(取名
// 叫 DA)裡，一句放陣列一個位置，最後讀檔成功，會回傳 true 值表讀檔成功，
// 在能執行接下來的解意。

function readFile(fn:string):boolean;
	var
		f:textfile;
		i,h,count:integer;
		ws:string;
	begin
		result:=false;
		if fileExists(fn)=false then exit;
		releaseData;
		assignfile(f,fn);
		filemode:=0;
		reset(f);
		count:=1;
		while not eof(f) do
		begin
			readln(f, ws);
			a[count]:=ws;
			inc(count);
			if count=3001 then
			begin
				h:=high(DA);
				setlength(DA,h+count);
				for i:=1 to count-1 do
				DA[i+h]:=a[i];
				count:=1;
			end;
		end;
		h:=high(DA);
		setlength(DA,h+count);
		for i:=1 to count-1 do DA[i+h]:=a[i];
		closefile(f);
		result:=true;
	end;
	
// 解意程式
// 此段程式功用是把之前讀檔讀到陣列(DA)裡的字串做解意，最後把資料放到
// 事先定 義好的資料形態裡。
procedure ResolveStr(s:string);
	var
		currCode,i,j,k,len,CurLenX,CurLenY:integer;
		ws:array[1..4] of string;
		tempPad:Padptr;
		tempLine:Lineptr;
		tempDraw:Drawptr;
	begin
		currCode:=4;
		len:=length(s);
		for i:=1 to 4 do ws[i]:='';
		for i:=1 to len do
		begin
			case s[i] of
				'G','g':
					begin
						if (s[i+1]='0') and (s[i+2]='4') or (s[i+1]='4') then break;
						if (s[i+1]='5') and (s[i+2]='4') then
						begin
							for j:=1 to len do
							begin
								case s[j] of
								'D','d':currCode:=1;
								'0'..'9','-','.':ws[currcode]:=ws[currcode]+s[j];
							end;
						end;
					CurAp:=strtoint(ws[1]);
					break;
					end;
				end;
		
				'F','f':
					begin
					LorT:=s[i+2];
					IntX:=strtoint(s[i+5]);
					DecX:=strtoint(s[i+6]);
					LenX:=IntX+DecX;
					IntY:=strtoint(s[i+8]);
					DecY:=strtoint(s[i+9]);
					LenY:=IntY+DecY;
					break;
				end;
				
				'M','m':
					begin
						if s[i+1]='O' then
						begin
							if s[i+2]='I' then mode:='Inch';
							if s[i+2]='M' then mode:='Millimeter';
							break;
						end
						else if (s[i+1]='0') and (s[i+2]='2') then
						begin
							if traceDraw^.PorL='P' then traceDraw^.Padto:=tracePad;
							if traceDraw^.PorL='L' then traceDraw^.Lineto:=traceLine;
							tracePad:=nil;
							traceLine:=nil;
							traceDraw:=nil;
						end;
					end;
		
				'A','a':
					begin
						if (s[i+1]='D') and (s[i+2]='D') then
						begin
							j:=strtoint(s[i+3]+s[i+4]);
							setlength(rAp,j-9);
							rAp[j-10].adCode:=j;
							rAp[j-10].tp:=s[i+5];
							for k:=1 to len do
							begin
								case s[k] of
								'C','c':currCode:=1;
								'R','r':currCode:=2;
								'X','x':currCode:=3;
								'0'..'9','-','.':ws[currcode]:=ws[currcode]+s[k];
							end;
						end;
						if currCode=1 then
						begin
							rAp[j-10].cir.d:=strtofloat(ws[1]);
							break;
						end
						else
						begin
							rAp[j-10].rec.w:=strtofloat(ws[2]);
							rAp[j-10].rec.h:=strtofloat(ws[3]);
							break;
						end;
					end;
				end;
		
				'L','l':
					begin
						currDorC:=s[i+2];
						break;
					end;
		
				'X','x':
					begin
					for k:=1 to len do
						begin
							case s[k] of
							'D','d':currCode:=1;
							'X','x':currcode:=2;
							'Y','y':currcode:=3;
							'0'..'9','-','.':ws[currcode]:=ws[currcode]+s[k];
						end;
					end;
		
			if LorT='T' then
			begin
				CurLenX:=length(ws[2]);
				CurLenY:=length(ws[3]);
				if ws[2][1]='-' then
				begin
					for k:=1 to (LenX-CurLenX+1) do
						begin
							ws[2]:=ws[2]+'0';
						end;
				end
				else
				begin
					for k:=1 to (LenX-CurLenX) do
						begin
							ws[2]:=ws[2]+'0';
						end;
				end;
				
				if ws[3][1]='-' then
				begin
					for k:=1 to (LenY-CurLenY+1) do
						begin
							ws[3]:=ws[3]+'0';
						end;
				end
				else
				begin
					for k:=1 to (LenY-CurLenY) do
						begin
							ws[3]:=ws[3]+'0';
						end;
				end;
			end;

			case ws[1] of
				'03':
				begin
					LineSelc:='03';
					new(tempPad);
					with tempPad^ do
					begin
						DorC:=currDorC;
						AD:=CurAp;
						x:=(strtofloat(ws[2])/power(10,DecX));
						y:=(strtofloat(ws[3])/power(10,DecY));
						next:=nil;
					end;
					if rPadLis=nil then
						begin
							rPadLis:=tempPad;
							tracePad:=tempPad;
						end
					else
						begin
							tracePad^.next:=tempPad;
							tracePad:=tempPad;
						end;
					if DrawLis=nil then
						begin
							new(tempDraw);
							with tempDraw^ do
							begin
								PorL:='P';
								Padfrom:=tempPad;
								next:=nil;
							end;
							DrawLis:=tempDraw;
							traceDraw:=tempDraw;
							break;
						end
					else if traceDraw^.PorL='L' then
						begin
							traceDraw^.Lineto:=traceLine;
							new(tempDraw);
							with tempDraw^ do
							begin
								PorL:='P';
								Padfrom:=tempPad;
								next:=nil;
							end;
							traceDraw^.next:=tempDraw;
							traceDraw:=tempDraw;
							break;
						end;
				end;
				
				'02':
				begin
					if LineSelc='02' then
						begin
							with traceLine^ do
							begin
								DorC:=currDorC;
								AD:=CurAp;
								x1:=(strtofloat(ws[2])/power(10,DecX));
								y1:=strtofloat(ws[3])/power(10,DecY);
							end;
							break;
						end
					else
					begin
						new(tempLine);
						with tempLine^ do
						begin
							DorC:=currDorC;
							AD:=CurAp;
							x1:=(strtofloat(ws[2])/power(10,DecX));
							y1:=strtofloat(ws[3])/power(10,DecY);
							next:=nil;
						end;
						if rLineLis=nil then
						begin
							rLineLis:=tempLine;
							traceLine:=tempLine;
						end
						else
						begin
							traceLine^.next:=tempLine;
							traceLine:=tempLine;
						end;
						LineSelc:='02';
						break;
					end;
				end;
				
				'01':
				begin
					if LineSelc='02' then
						begin
							traceLine^.x2:=strtofloat(ws[2])/power(10,DecX);
							traceLine^.y2:=strtofloat(ws[3])/power(10,DecY);
							LineSelc:='01';
						end
					else if LineSelc='03' then
						begin
							new(tempLine);
							with tempLine^ do
							begin
								DorC:=currDorC;
								AD:=CurAp;
								x1:=tracePad^.x;
								y1:=tracePad^.y;
								x2:=(strtofloat(ws[2])/power(10,DecX));
								y2:=strtofloat(ws[3])/power(10,DecY);
								next:=nil;
						end;
						
					if rLineLis=nil then
						begin
							rLineLis:=tempLine;
							traceLine:=tempLine;
						end
					else
						begin
							traceLine^.next:=tempLine;
							traceLine:=tempLine;
						end;
					
					LineSelc:='01'
					end					
					else if LineSelc='01' then
						begin
							new(tempLine);
							with tempLine^ do
							begin
								DorC:=currDorC;
								AD:=CurAp;
								x1:=traceLine^.x2;
								y1:=traceLine^.y2;
								x2:=(strtofloat(ws[2])/power(10,DecX));
								y2:=strtofloat(ws[3])/power(10,DecY);
								next:=nil;
							end;
							if rLineLis=nil then
							begin
								rLineLis:=tempLine;
								traceLine:=tempLine;
						end
					else
						begin
							traceLine^.next:=tempLine;
							traceLine:=tempLine;
						end;
					
					LineSelc:='01'
					end;
					
					if DrawLis=nil then
						begin
							new(tempDraw);
							with tempDraw^ do
							begin
								PorL:='L';
								Linefrom:=tempLine;
								next:=nil;
							end;
							DrawLis:=tempDraw;
							traceDraw:=tempDraw;
							break;
						end
					else if traceDraw^.PorL='P' then
						begin
							traceDraw^.Padto:=tracePad;
							new(tempDraw);
							with tempDraw^ do
							begin
								PorL:='L';
								Linefrom:=tempLine;
								next:=nil;
							end;
							traceDraw^.next:=tempDraw;
							traceDraw:=tempDraw;
							break;
						end;
					end;
					end;
				end;
			end;
		end;
	end;


// 畫圖程式
procedure TForm1.PaintBox1Paint(Sender: TObject);
	var
		h1,i,ApCode,cx,cy,d,cx1,cy1,cx2,cy2:integer;
		h,w,rx,ry,rx1,ry1,rx2,ry2,Sx,Sy,Bx,By,m:double;
		pts1:array[0..3] of TPoint;
		pts2:array[0..5] of TPoint;
		PDraTra:Padptr;
		LDraTra:Lineptr;
		Drawtrace:Drawptr;
		begin
			PDraTra:=nil;
			LDraTra:=nil;
			Drawtrace:=nil;
			bit := TBitmap.Create;
			bit.SetSize(paintbox1.width, paintbox1.height);
			ResolveDisplay;
	Drawtrace:=DrawLis;
	repeat
	if Drawtrace=nil then break
	else if Drawtrace^.PorL='P' then
	begin
	PDratra:=Drawtrace^.Padfrom;
	repeat
	ApCode:=PDratra^.AD-10;
	if PDratra^.DorC='D' then
		begin
			bit.canvas.pen.color:=clred;
			bit.canvas.brush.color:=clred;
		end
	else if PDratra^.DorC='S' then
		begin
			bit.canvas.pen.color:=clgreen;
			bit.canvas.brush.color:=clgreen;
		end
	else
		begin
			bit.canvas.pen.color:=clblack;
			bit.canvas.brush.color:=clblack;
		end;
		
	if rAp[ApCode].tp='C' then
		begin
			d:=round(rAp[ApCode].cir.d/scale);
			cx:=round(paintbox1.width/2+(PDratra^.x-rCX)/scale);
			cy:=round(paintbox1.height/2-(PDratra^.y-rCY)/scale);
			bit.canvas.pen.Width:=d;
			bit.canvas.moveto(cx,cy);
			bit.canvas.lineto(cx,cy);
		end
	else if rAp[ApCode].tp='R' then
		begin
			h:=rAp[ApCode].rec.h/scale;
			w:=rAp[ApCode].rec.w/scale;
			rx:=paintbox1.width/2+(PDratra^.x-rCX)/scale;
			ry:=paintbox1.height/2-(PDratra^.y-rCY)/scale;
			pts1[0]:=point(round(rx-w/2),round(ry-h/2));
			pts1[1]:=point(round(rx-w/2),round(ry+h/2));
			pts1[2]:=point(round(rx+w/2),round(ry+h/2));
			pts1[3]:=point(round(rx+w/2),round(ry-h/2));
			bit.canvas.pen.Width:=1;
			bit.Canvas.Polygon(pts1);
		end;
	PDratra:=PDratra^.next;
	until PDratra=Drawtrace^.Padto^.next;
	end
	else if Drawtrace^.PorL='L' then
	begin
	LDratra:=Drawtrace^.Linefrom;
	repeat
	ApCode:=LDratra^.AD-10;
	if LDratra^.DorC='D' then
		begin
			bit.canvas.pen.color:=clred;
			bit.canvas.brush.color:=clred;
		end
	else if LDratra^.DorC='S' then
		begin
			bit.canvas.pen.color:=clgreen;
			bit.canvas.brush.color:=clgreen;
		end
	else
		begin
			bit.canvas.pen.color:=clblack;
			bit.canvas.brush.color:=clblack;
		end;
	if rAp[ApCode].tp='C' then
		begin
			d:=round(rAp[ApCode].cir.d/scale);
			cx1:=round(paintbox1.width/2+(LDratra^.x1-rCX)/scale);
			cy1:=round(paintbox1.height/2-(LDratra^.y1-rCY)/scale);
			cx2:=round(paintbox1.width/2+(LDratra^.x2-rCX)/scale);
			cy2:=round(paintbox1.height/2-(LDratra^.y2-rCY)/scale);
			bit.canvas.pen.Width:=d;
			bit.canvas.moveto(cx1,cy1);
			bit.canvas.lineto(cx2,cy2);
		end
	else if rAp[ApCode].tp='R' then
		begin
		h:=rAp[ApCode].rec.h/scale;
		w:=rAp[ApCode].rec.w/scale;
		rx1:=paintbox1.width/2+(LDratra^.x1-rCX)/scale;
		ry1:=paintbox1.height/2-(LDratra^.y1-rCY)/scale;
		rx2:=paintbox1.width/2+(LDratra^.x2-rCX)/scale;
		ry2:=paintbox1.height/2-(LDratra^.y2-rCY)/scale;
		Sx:=Min(rx1,rx2); Sy:=Min(ry1,ry2);
		Bx:=Max(rx1,rx2); By:=Max(ry1,ry2);
		if rx1=rx2 then
			begin
				pts1[0]:=point(round(rx1-w/2),round(By+h/2));
				pts1[1]:=point(round(rx1+w/2),round(By+h/2));
				pts1[2]:=point(round(rx2+w/2),round(Sy-h/2));
				pts1[3]:=point(round(rx2-w/2),round(Sy-h/2));
				bit.canvas.pen.Width:=1;
				bit.Canvas.Polygon(pts1);
			end
	else if ry1=ry2 then
		begin
			pts1[0]:=point(round(Sx-w/2),round(ry1-h/2));
			pts1[1]:=point(round(Sx-w/2),round(ry1+h/2));
			pts1[2]:=point(round(Bx+w/2),round(ry2+h/2));
			pts1[3]:=point(round(Bx+w/2),round(ry2-h/2));
			bit.canvas.pen.Width:=1;
			bit.Canvas.Polygon(pts1);
		end
	else if (rx1<>rx2) and (ry1<>ry2) then
	begin
	m:=(ry2-ry1)/(rx2-rx1);
	if m>0 then
		begin
			pts2[0]:=point(round(Sx-w/2),round(Sy+h/2));
			pts2[1]:=point(round(Sx-w/2),round(Sy-h/2));
			pts2[2]:=point(round(Sx+w/2),round(Sy-h/2));
			pts2[3]:=point(round(Bx+w/2),round(By-h/2));
			pts2[4]:=point(round(Bx+w/2),round(By+h/2));
			pts2[5]:=point(round(Bx-w/2),round(By+h/2));
			bit.canvas.pen.Width:=1;
			bit.Canvas.Polygon(pts2);
		end
	else if m<0 then
		begin
			pts2[0]:=point(round(Sx-w/2),round(By-h/2));
			pts2[1]:=point(round(Sx-w/2),round(By+h/2));
			pts2[2]:=point(round(Sx+w/2),round(By+h/2));
			pts2[3]:=point(round(Bx+w/2),round(Sy+h/2));
			pts2[4]:=point(round(Bx+w/2),round(Sy-h/2));
			pts2[5]:=point(round(Bx-w/2),round(Sy-h/2));
			bit.canvas.pen.Width:=1;
			bit.Canvas.Polygon(pts2);
		end;
	end;
	end;
	LDratra:=LDratra^.next;
	until LDratra=Drawtrace^.Lineto^.next;
	end;
	Drawtrace:=Drawtrace^.next;
	until Drawtrace=nil;
	paintbox1.canvas.brush.color:=clblack;
	paintbox1.canvas.pen.color:=clblack;
	paintbox1.canvas.pen.mode:=pmCopy;
	paintbox1.canvas.rectangle(0,0,paintbox1.width,paintbox1.height);
	BitBlt(PaintBox1.Canvas.Handle, 0, 0, paintbox1.width,paintbox1.height,
	bit.Canvas.Handle, 0, 0, SRCPaint);
	end;
	
// 圖形的資料查詢
// 傳入想要搜尋圖形的螢幕座標到此程式，此程式執行搜尋 Pad 跟 Line 兩個
// Linked-List 的資料裡是否有符合的資料，要有找到則把圖形顏色轉變成綠色，
// 把資料傳到 ListBox 裡，要是沒找到則不做任何動作。

procedure Search(x,y:integer);
	var
		ApCode:integer;
		rX,rY,d,d1,d2,x1,y1,x2,y2,m,Bx,Sx,By,Sy,
		s1,t1,u1,v1,s2,t2,u2,v2,r,p,h,w:double;
		Queflg:boolean;
		LastPad:Padptr;
		LastLine:Lineptr;
	begin
		rX:=(x-Form1.PaintBox1.Width/2)*scale+rCX;
		rY:=((y-Form1.PaintBox1.Height/2)*scale-rCY)*-1;
		Queflg:=false;
		tracePad:=rPadLis;
		traceLine:=rLineLis;
		repeat
		if rPadLis=nil then break;
		if (tracePad^.DorC='D') or (tracePad^.DorC='S') then
		begin
		ApCode:=tracePad^.AD-10;
		case rAp[ApCode].tp of
			'C':
				begin
					d:=sqrt(sqr(rX-tracePad^.x)+sqr(rY-tracePad^.y));
					r:=rAp[ApCode].cir.d/2;
					if d<r then
						begin
							if (tracePad^.DorC='S')and(DelMod=true) then
							begin
								DeletePad(LastPad,tracePad);
								break;
							end;
							FindCirPad(ApCode);
							Queflg:=true;
						end
					else if tracePad^.DorC='S' then
						begin
							tracePad^.DorC:='D';
							SearchYorN:=true;
						end;
				end;
			
			'R':
				begin
					w:=rAp[ApCode].rec.w;
					h:=rAp[ApCode].rec.h;
					if (rX>tracePad^.x-w/2) and (rX<tracePad^.x+w/2)
					and (rY>tracePad^.y-h/2) and (rY<tracePad^.y+h/2)
					then begin
					if (tracePad^.DorC='S')and(DelMod=true) then
						begin
							DeletePad(LastPad,tracePad);
							break;
						end;
					FindRecPad(ApCode);
					Queflg:=true;
				end
			else if tracePad^.DorC='S' then
				begin
					tracePad^.DorC:='D';
					SearchYorN:=true;
				end;
			end;
			end;
			end;
			
			LastPad:=tracePad;
			tracePad:=tracePad^.next;
			until tracePad=nil;
			repeat
				if rLineLis=nil then break;
				x1:=Form1.paintbox1.width/2+(traceLine^.x1-rCX)/scale;
				y1:=Form1.paintbox1.height/2-(traceLine^.y1-rCY)/scale;
				x2:=Form1.paintbox1.width/2+(traceLine^.x2-rCX)/scale;
				y2:=Form1.paintbox1.height/2-(traceLine^.y2-rCY)/scale;
				Sx:=Min(x1,x2); Sy:=Min(y1,y2);
				Bx:=Max(x1,x2); By:=Max(y1,y2);
				ApCode:=traceLine^.AD-10;
			
			if (traceLine^.DorC='D') or (traceLine^.DorC='S') then
			begin
			case rAp[ApCode].tp of	
			'C':
				begin
					d1:=Min(sqrt(sqr(x-x1)+sqr(y-y1)),sqrt(sqr(x-x2)+sqr(y-y2)));
					r:=(rAp[ApCode].cir.d/scale)/2;
					if x1=x2 then
					begin
					if(d1<r)or((x1-r<x)and(x<x1+r)and (Sy<x)and(y<By)) then
						begin
							if (traceLine^.DorC='S')and(DelMod=true) then
								begin
									DeleteLine(LastLine,traceLine);
									break;
								end;
							FindCirLin(ApCode);
							Queflg:=true;
						end
					else if traceLine^.DorC='S' then
						begin
							traceLine^.DorC:='D';
							SearchYorN:=true;
						end;
				end
			else if y1=y2 then
				begin
				if(d1<r)or( (y1-r<y)and(y<y1+r)and(Sx<x)and(x<Bx) ) then
					begin
					if (traceLine^.DorC='S')and(DelMod=true) then
						begin
							DeleteLine(LastLine,traceLine);
							break;
						end;
					FindCirLin(ApCode);
					Queflg:=true;
					end
				else if traceLine^.DorC='S' then
					begin
						traceLine^.DorC:='D';
						SearchYorN:=true;
					end;
			end
			else if (x1<>x2) and (y1<>y2) then
				begin
					m:=(y2-y1)/(x2-x1);
					d2:=sqrt(sqr(x-(m*y+x-m*y1+m*m*x1)/(m*m+1))+sqr(y-(m*m*y+m*x+y1-m*x1)/(m*
					m+1)));
					if m>0 then
					begin
						p:=r/sqrt(1+sqr(-1/m)); s1:=Sx-p; t1:=Sy+(1/m)*p;
						u1:=Sx+p; v1:=Sy-(1/m)*p; s2:=Bx-p; t2:=By+(1/m)*p;
						u2:=Bx+p; v2:=By-(1/m)*p;
						if(d1<r)or(((s1<x)and(x<u2)and(v1<y)and(y<t2))and (d2<r)) then
							begin
								if (traceLine^.DorC='S')and(DelMod=true) then
									begin
										DeleteLine(LastLine,traceLine);
										break;
										FindCirLin(ApCode);
										Queflg:=true;
									end
								else if traceLine^.DorC='S' then
									begin
										traceLine^.DorC:='D';
										SearchYorN:=true;
									end;
							end
						else if m<0 then
						begin
						p:=r/sqrt(1+sqr(-1/m)); s1:=Sx-p; t1:=By-(-1/m)*p;
						u1:=Sx+p; v1:=By+(-1/m)*p; s2:=Bx-p; t2:=Sy-(-1/m)*p;
						u2:=Bx+p; v2:=Sy+(-1/m)*p;
						if(d1<r)or(((s1<x)and(x<u2)and(t2<y)and(y<v1))and (d2<r)) then
						begin
							if (traceLine^.DorC='S')and(DelMod=true) then
								begin
									DeleteLine(LastLine,traceLine);
									break;
								end;
							FindCirLin(ApCode);
							Queflg:=true;
							end
							else if traceLine^.DorC='S' then
								begin
									traceLine^.DorC:='D';
									SearchYorN:=true;
								end;
						end;
					end;
				end;
			
			'R':
			begin
			h:=rAp[ApCode].rec.h/scale;
			w:=rAp[ApCode].rec.w/scale;
			if x1=x2 then
				begin
				if(x1-w/2<x)and(x<x1+w/2)and (Sy-h/2<x)and(y<By+h/2) then
					begin
						if (traceLine^.DorC='S')and(DelMod=true) then
							begin
								DeleteLine(LastLine,traceLine);
								break;
							end;
						FindRecLin(ApCode);
						Queflg:=true;
					end
				else if traceLine^.DorC='S' then
					begin
						traceLine^.DorC:='D';
						SearchYorN:=true;
					end;
				end
			else if y1=y2 then
				begin
				if (y1-h/2<y)and(y<y1+h/2)and(Sx-w/2<x)and(x<Bx+h/2) then
					begin
						if (traceLine^.DorC='S')and(DelMod=true) then
							begin
								DeleteLine(LastLine,traceLine);
								break;
							end;
						FindRecLin(ApCode);
						Queflg:=true;
					end
				else if traceLine^.DorC='S' then
					begin
						traceLine^.DorC:='D';
						SearchYorN:=true;
					end;
				end
			else if (x1<>x2) and (y1<>y2) then
			begin
			m:=(y2-y1)/(x2-x1);
			d2:=sqrt(sqr(x-(m*y+x-m*y1+m*m*x1)/(m*m+1))
			+sqr(y-(m*m*y+m*x+y1-m*x1)/(m*m+1)));
			r:=sqrt(sqr(w/2)+sqr(h/2));
			if m>0 then
				begin
				s1:=Sx-w/2; u2:=Bx+w/2;
				v1:=Sy-h/2; t2:=By+h/2;
				if ((s1<x)and(x<u2)and(v1<y)and(y<t2)) and (d2<r) then
					begin
						if (traceLine^.DorC='S')and(DelMod=true) then
							begin
								DeleteLine(LastLine,traceLine);
								break;
							end;
						FindRecLin(ApCode);
						Queflg:=true;
					end
				else if traceLine^.DorC='S' then
					begin
						traceLine^.DorC:='D';
						SearchYorN:=true;
					end;
				end
			else if m<0 then
				begin
				s1:=Sx-w/2; u2:=Bx+w/2;
				v1:=By+h/2; t2:=Sy-h/2;
				if ((s1<x)and(x<u2)and(t2<y)and(y<v1)) and (d2<r) then
					begin
					if (traceLine^.DorC='S')and(DelMod=true) then
						begin
							DeleteLine(LastLine,traceLine);
							break;
						end;
					FindRecLin(ApCode);
					Queflg:=true;
					end
				else if traceLine^.DorC='S' then
					begin
						traceLine^.DorC:='D';
						SearchYorN:=true;
					end;
				end;
			end;
			end;
			end;
			end;
			LastLine:=traceLine;
			traceLine:=traceLine^.next;
			until traceLine=nil;
			if Queflg=false then
				begin
					Form1.Listbox1.clear;
					Form1.Listbox2.clear;
					Form1.Listbox3.clear;
					Form1.Listbox4.clear;
				end;
	end;

// 圖形的新增
// 此程式功能是在 Pad 或 Line 的 Linked-List 建立新的圖形資料。
procedure Draw(NewX,NewY:integer);
	var
		h1:integer;
		tempPad,Padtrace:Padptr;
		tempLine,Linetrace:Lineptr;
		tempDraw,Drawtrace:Drawptr;
		begin
		if SetOK=true then
	begin
		h1:=high(rAp);
		if Dratype='P' then
		begin
			Padtrace:=rPadLis;
			repeat
			if Padtrace=nil then
				begin
					new(tempPad);
					with tempPad^ do
						begin
							DorC:='D';
							AD:=h1+10;
							x:=(NewX-Form1.PaintBox1.Width/2)*scale+rCX;
							y:=((NewY-Form1.PaintBox1.Height/2)*scale-rCY)*-1;
							next:=nil;
						end;
					rPadLis:=tempPad;
					break;
				end
			else if Padtrace^.next=nil then
				begin
					new(tempPad);
					with tempPad^ do
						begin
							DorC:='D';
							AD:=h1+10;
							x:=(NewX-Form1.PaintBox1.Width/2)*scale+rCX;
							y:=((NewY-Form1.PaintBox1.Height/2)*scale-rCY)*-1;
							next:=nil;
						end;
					Padtrace^.next:=tempPad;
					break;
				end;
			Padtrace:=Padtrace^.next;
			until Padtrace=nil;
			Drawtrace:=DrawLis;
			repeat
				if Drawtrace^.next=nil then
					begin
						new(tempDraw);
						with tempDraw^ do
							begin
								PorL:=Dratype;
								Padfrom:=tempPad;
								Padto:=tempPad;
								next:=nil;
							end;
						Drawtrace^.next:=tempDraw;
						break;
					end;
				Drawtrace:=Drawtrace^.next;
				until Drawtrace=nil
				end
			else if Dratype='L' then
			begin
			Linetrace:=rLineLis;
			if FirstPoint=true then
			begin
			repeat
			if Linetrace=nil then
				begin
					new(tempLine);
					with tempLine^ do
						begin
							DorC:='D';
							AD:=h1+10;
							x1:=(NewX-Form1.PaintBox1.Width/2)*scale+rCX;
							y1:=((NewY-Form1.PaintBox1.Height/2)*scale-rCY)*-1;
							next:=nil;
						end;
					rLineLis:=tempLine;
					FirstPoint:=false;
					break;
				end
			else if Linetrace^.next=nil then
			begin
				new(tempLine);
				with tempLine^ do
					begin
						DorC:='D';
						AD:=h1+10;
						x1:=(NewX-Form1.PaintBox1.Width/2)*scale+rCX;
						y1:=((NewY-Form1.PaintBox1.Height/2)*scale-rCY)*-1;
						next:=nil;
					end;
				Linetrace^.next:=tempLine;
				FirstPoint:=false;
				break;
		end;
		Linetrace:=Linetrace^.next;
		until Linetrace=nil;

// 圖形的刪減
// 這兩個程式，分別功能是，刪除 Pad 鏈結裡的資料，刪除 Line 鏈結裡的資
// 料。
procedure DeletePad(Lastnode,NodePad:Padptr); //刪除 Pad 的程式
	var
		LastDraw,Drawtrace:Drawptr;
		begin
		Drawtrace:=DrawLis;
		repeat
		if Drawtrace^.PorL='P' then
	begin
		if (Drawtrace^.Padfrom=NodePad)and
		(Drawtrace^.Padfrom=Drawtrace^.Padto)
		then begin
				LastDraw:=Drawtrace^.next;
				dispose(Drawtrace);
				break;
			end
		else if Drawtrace^.Padfrom=NodePad then
			begin
				Drawtrace^.Padfrom:=NodePad^.next;
				break;
			end
		else if Drawtrace^.Padto=NodePad then
			begin
				Drawtrace^.Padto:=Lastnode;
				break;
			end;
		end;
		LastDraw:=Drawtrace;
		Drawtrace:=Drawtrace^.next;
		until Drawtrace=nil;
		if NodePad=rPadLis then
			begin
				rPadLis:=NodePad^.next;
				dispose(NodePad);
			end
		else begin
				Lastnode^.next:=NodePad^.next;
				dispose(NodePad);
			end;
		Form1.Listbox1.clear;
		Form1.Listbox2.clear;
		Form1.Listbox3.clear;
		Form1.Listbox4.clear;
		end;
		
		procedure DeleteLine(Lastnode,NodeLine:Lineptr); //刪除 Line 的程式
		var
		LastDraw,Drawtrace:Drawptr;
		begin
		Drawtrace:=DrawLis;
		repeat
		if Drawtrace^.PorL='L' then
		begin
		if (Drawtrace^.Linefrom=NodeLine)and
		(Drawtrace^.Linefrom=Drawtrace^.Lineto)
		then begin
				LastDraw:=Drawtrace^.next;
				dispose(Drawtrace);
				break;
			end
		else if Drawtrace^.Linefrom=NodeLine then
			begin
				Drawtrace^.Linefrom:=NodeLine^.next;
				break;
			end
		else if Drawtrace^.Lineto=NodeLine then
			begin
				Drawtrace^.Lineto:=Lastnode;
				break;
			end;
		end;
		LastDraw:=Drawtrace;
		Drawtrace:=Drawtrace^.next;
		until Drawtrace=nil;
		if NodeLine=rLineLis then
			begin
				rLineLis:=NodeLine^.next;
				dispose(NodeLine);
			end
		else begin
				Lastnode^.next:=NodeLine^.next;
				dispose(NodeLine);
			end;
		Form1.Listbox1.clear;
		Form1.Listbox2.clear;
		Form1.Listbox3.clear;
		Form1.Listbox4.clear;
	end;
